open Syntax

let rec evaluated = function
  | Fun (_, _) -> true
  | u -> partial_application 0 u

and partial_application n = function
  | Const c -> c.constr || c.arity > n
  | App (u, v) -> evaluated v && partial_application (n + 1) u
  | _ -> false

exception Reduce

let delta_bin_arith op code = function
  | App
      ( App
          ( (Const { name = Name _; arity = 2; constr = _ } as c),
            Const { name = Int x; _ } ),
        Const { name = Int y; _ } )
    when c = op -> int (code x y)
  | _ -> raise Reduce

let delta_plus = delta_bin_arith plus ( + )

let delta_times = delta_bin_arith times ( * )

let delta_rules = [ delta_plus; delta_times ]

let union f g a = try g a with Reduce -> f a

let delta = List.fold_right union delta_rules (fun _ -> raise Reduce)

let rec subst x v a =
  assert (evaluated v);
  match a with
  | Var y -> if x = y then v else a
  | Fun (y, a') -> if x = y then a else Fun (y, subst x v a')
  | App (a', a'') -> App (subst x v a', subst x v a'')
  | Let (y, a', a'') ->
      if x = y then Let (y, subst x v a', a'')
      else Let (y, subst x v a', subst x v a'')
  | Const _ -> a

let beta = function
  | App (Fun (x, a), v) when evaluated v -> subst x v a
  | Let (x, v, a) when evaluated v -> subst x v a
  | _ -> raise Reduce

let top_reduction = union beta delta

let rec eval =
  let eval_top_reduce a = try eval (top_reduction a) with Reduce -> a in
  function
  | App (a1, a2) ->
      let v1 = eval a1 in
      let v2 = eval a2 in
      eval_top_reduce (App (v1, v2))
  | Let (x, a1, a2) ->
      let v1 = eval a1 in
      eval_top_reduce (Let (x, v1, a2))
  | a -> eval_top_reduce a

let rec eval_step = function
  | App (a1, a2) when not (evaluated a1) -> App (eval_step a1, a2)
  | App (a1, a2) when not (evaluated a2) -> App (a1, eval_step a2)
  | Let (x, a1, a2) when not (evaluated a1) -> Let (x, eval_step a1, a2)
  | a -> top_reduction a

type context = expr -> expr

let hole : context = fun t -> t

let appL a t = App (t, a)

let appR a t = App (a, t)

let letL x a t = Let (x, t, a)

let ( ** ) e1 (e0, a0) = ((fun a -> e1 (e0 a)), a0)

let rec eval_context : expr -> context * expr = function
  | App (a1, a2) when not (evaluated a1) -> appL a2 ** eval_context a1
  | App (a1, a2) when not (evaluated a2) -> appR a1 ** eval_context a2
  | Let (x, a1, a2) when not (evaluated a1) -> letL x a2 ** eval_context a1
  | a -> (hole, a)

let eval_step a =
  let c, t = eval_context a in
  c (top_reduction t)

let rec eval a = try eval (eval_step a) with Reduce -> a

(** Exercise *)

type context =
  | Top
  | AppL of context * expr
  | AppR of value * context
  | LetL of string * context * expr

and value = int * expr

let rec fill_context : context * expr -> expr = function
  | Top, e -> e
  | AppL (c, l), e -> fill_context (c, App (e, l))
  | AppR ((_, e1), c), e2 -> fill_context (c, App (e1, e2))
  | LetL (x, c, e2), e1 -> fill_context (c, Let (x, e1, e2))

exception Error of context * expr

exception Value of int

let rec decompose_down : context * expr -> context * expr =
 fun ((c, e) as ce) ->
  match e with
  | Var _ -> raise (Error (c, e))
  | Const c when c.constr -> raise (Value (c.arity + 1))
  | Const c -> raise (Value c.arity)
  | Fun (_, _) -> raise (Value 1)
  | Let (x, e1, e2) -> decompose_down (LetL (x, c, e2), e1)
  | App (e1, e2) -> (
      try decompose_down (AppL (c, e2), e1)
      with Value k1 -> (
        try decompose_down (AppR ((k1, e2), c), e2)
        with Value _ -> if k1 > 1 then raise (Value (k1 - 1)) else ce ) )

let rec decompose_up k ((c, v) as cv) =
  if k > 0 then
    match c with
    | Top -> raise Not_found
    | LetL (x, c', e) -> (c', Let (x, v, e))
    | AppR ((k', v'), c') -> decompose_up (k' - 1) (c', App (v', v))
    | AppL (c', e) -> (
        try decompose_down (AppR ((k, v), c'), e)
        with Value _ -> decompose_up (k - 1) (c', App (v, e)) )
  else cv

let decompose ce = try decompose_down ce with Value k -> decompose_up k ce

let reduce_in ((c : context), e) = (c, top_reduction e)

let eval_step ce = reduce_in (decompose ce)

let rec eval_all ce = try eval_all (eval_step ce) with Not_found -> ce

let eval e = fill_context (eval_all (Top, e))

let hole = Const { name = Name "[]"; arity = 0; constr = true }

let rec expr_with expr_in_hole k out =
  let expr = expr_with expr_in_hole in
  let string x = Format.fprintf out x in
  let paren p f =
    if k > p then string "(";
    f ();
    if k > p then string ")"
  in
  function
  | Var x -> string "%s" x
  | Const _ as c when c = hole -> string "[%a]" (expr_with hole 0) expr_in_hole
  | Const { name = Int n; _ } -> string "%d" n
  | Const { name = Name c; _ } -> string "%s" c
  | Fun (x, a) -> paren 0 (fun () -> string "fun %s -> %a" x (expr 0) a)
  | App (App (Const { name = Name (("+" | "*") as n); _ }, a1), a2) ->
      paren 1 (fun () -> string "%a %s %a" (expr 2) a1 n (expr 2) a2)
  | App (a1, a2) -> paren 1 (fun () -> string "%a %a" (expr 1) a1 (expr 2) a2)
  | Let (x, a1, a2) ->
      paren 0 (fun () -> string "let %s = %a in %a" x (expr 0) a1 (expr 0) a2)

let print_context_expr (c, e) =
  expr_with e 0 Format.std_formatter (fill_context (c, hole))

let print_expr e = expr_with hole 0 Format.std_formatter e

let print_context c = print_expr (fill_context (c, hole))

(** Big-step operational semantics *)

type env = (string * value) list

and value = Closure of var * expr * env | Constant of constant * value list

type answer = Error | Value of value

let val_int u =
  Value (Constant ({ name = Int u; arity = 0; constr = true }, []))

let delta c l =
  match (c.name, l) with
  | ( Name "+",
      [ Constant ({ name = Int u; _ }, []); Constant ({ name = Int v; _ }, []) ]
    ) -> val_int (u + v)
  | ( Name "*",
      [ Constant ({ name = Int u; _ }, []); Constant ({ name = Int v; _ }, []) ]
    ) -> val_int (u * v)
  | _ -> Error

let get x env = try Value (List.assoc x env) with Not_found -> Error

let rec eval env = function
  | Var x -> get x env
  | Const c -> Value (Constant (c, []))
  | Fun (x, a) -> Value (Closure (x, a, env))
  | Let (x, a1, a2) -> (
      match eval env a1 with
      | Value v1 -> eval ((x, v1) :: env) a2
      | Error -> Error )
  | App (a1, a2) -> (
      match eval env a1 with
      | Value v1 -> (
          match (v1, eval env a2) with
          | Constant (c, l), Value v2 ->
              let k = List.length l + 1 in
              if c.arity < k then Error
              else if c.arity > k then Value (Constant (c, v2 :: l))
              else if c.constr then Value (Constant (c, v2 :: l))
              else delta c (v2 :: l)
          | Closure (x, e, env0), Value v2 -> eval ((x, v2) :: env0) e
          | _, Error -> Error )
      | Error -> Error )

(** The language: lambda-calculus with let *)

type varname = string

type exp =
  | Var of varname
  | App of exp * exp
  | Lam of varname * exp
  | Let of varname * exp * exp

(** The types to infer.

    Types without QVar (quantified variables) are simple types; those containing
    QVar are type schemas. Since quantifiers are always on the outside in the HM
    system, they are implied and not explicitly represented. *)

type qname = string
type level = int

type typ = TVar of tv ref | QVar of qname | TArrow of typ * typ
and tv = Unbound of string * level | Link of typ

let gensym_counter = ref 0
let reset_gensym () = gensym_counter := 0

let gensym () =
  let n = !gensym_counter in
  incr gensym_counter;
  if n < 26 then String.make 1 (Char.chr (Char.code 'a' + n))
  else "t" ^ string_of_int n


(** Determining the let-nesting level during the type-checking, or just the
    level. Each top-level expression to type check is implicitly wrapped into a
    let. So the numbering starts with 1. *)
let current_level = ref 1

let reset_level () = current_level := 1

let reset_type_variables () =
  reset_gensym ();
  reset_level ()


let enter_level () = incr current_level
let leave_level () = decr current_level

(** Make a fresh type variable and an arrow type*)
let newvar () = TVar (ref (Unbound (gensym (), !current_level)))

(** Check to see if a TVar (the first argument) occurs in the type given as the
    second argument. Fail if it does. At the same time, update the levels of all
    encountered free variables to be the min of variable's current level and the
    level of the given variable tvr. *)
let rec occurs : tv ref -> typ -> unit =
 fun tvr -> function
  | TVar tvr' when tvr == tvr' -> failwith "occurs check"
  | TVar ({ contents = Unbound (name, l') } as tv) ->
      let min_level =
        match !tvr with
        | Unbound (_, l) -> min l l'
        | _ -> l'
      in
      tv := Unbound (name, min_level)
  | TVar { contents = Link ty } -> occurs tvr ty
  | TArrow (t1, t2) ->
      occurs tvr t1;
      occurs tvr t2
  | _ -> ()


(** Simplistic. No path compression. Also, QVar are unexpected: they should've
    been instantiated. *)
let rec unify t1 t2 =
  if t1 == t2 then ()
  else
    match (t1, t2) with
    | TVar ({ contents = Unbound _ } as tv), t'
    | t', TVar ({ contents = Unbound _ } as tv) ->
        occurs tv t';
        tv := Link t'
    | TVar { contents = Link t1 }, t2 | t1, TVar { contents = Link t2 } ->
        unify t1 t2
    | TArrow (tl1, tl2), TArrow (tr1, tr2) ->
        unify tl1 tr1;
        unify tl2 tr2
    | _ -> failwith "unification"


type env = (varname * typ) list

(** Sound generalization: generalize (convert to QVar) only those free TVar
    whose level is greater than the current. These TVar correspond to ead
    regions. *)
let rec gen = function
  | TVar { contents = Unbound (name, l) } when l > !current_level -> QVar name
  | TVar { contents = Link ty } -> gen ty
  | TArrow (t1, t2) -> TArrow (gen t1, gen t2)
  | ty -> ty


(** Instantiation: replace schematic variables with fresh TVar *)
let inst =
  let rec loop subst = function
    | QVar name -> (
        try (List.assoc name subst, subst)
        with Not_found ->
          let tv = newvar () in
          (tv, (name, tv) :: susbt))
    | TVar { contents = Link ty } -> loop subst ty
    | TArrow (t1, t2) ->
        let t1, subst = loop subst t1 in
        let t2, subst = loop subst t2 in
        (TArrow (t1, t2), subst)
    | t -> (t, subst)
  in
  fun t -> fst (loop [] t)


(** Trivial type checker. Type checking errors are delivered as exceptions. *)
let rec typeof : env -> exp -> typ =
 fun env -> function
  | Var x -> inst (List.assoc x env)
  | Lam (x, e) ->
      let ty_x = newvar () in
      let ty_e = typeof ((x, ty_x) :: env) e in
      TArrow (ty_x, ty_e)
  | App (e1, e2) ->
      let ty_fun = typeof env e1 in
      let ty_arg = typeof env e2 in
      let ty_res = newvar () in
      unify ty_fun (TArrow (ty_arg, ty_res));
      ty_res
  | Let (x, e, e2) ->
      enter_level ();
      let ty_e = typeof env e in
      leave_level ();
      typeof ((x, gen ty_e) :: env) e2

type input =
  { text : string
  ; pos : int
  }

let consume_input (input : input) (start : int) (len : int) : input =
  { text = String.sub input.text start len; pos = input.pos + start }
;;

(** create [input] from string *)
let input_of (s : string) : input = { text = s; pos = 0 }

type 'a parser = { run : input -> input * ('a, string) result }

(** [return v] creates a parser that will always succeed and return [v] *)
let return (v : 'a) : 'a parser = { run = (fun input -> input, Ok v) }

(** [fail msg] creates a parser that will always fail with the error
   message [msg] *)
let fail (err : string) : 'a parser = { run = (fun input -> input, Error err) }

(** [bind p f] or [p >>= f] creates a parser that will run [p], pass
   its result to [f], run the parser that [f] produces, and return its
   result.  *)
let bind (p : 'a parser) (f : 'a -> 'b parser) : 'b parser =
  { run =
      (fun input ->
        match p.run input with
        | input', Ok x -> (f x).run input'
        | input', Error err -> input', Error err)
  }
;;

let ( >>= ) = bind

let any_char : char parser =
  { run =
      (fun input ->
        let n = String.length input.text in
        try consume_input input 1 (n - 1), Ok (String.get input.text 0) with
        | Invalid_argument _ -> input, Error "no char")
  }
;;

let peek_char : char parser =
  { run =
      (fun input ->
        try input, Ok (String.get input.text 0) with
        | Invalid_argument _ -> input, Error "no char")
  }
;;

let satisfy (f : char -> bool) : char parser =
  peek_char >>= fun c -> if f c then any_char else fail "not satisfied"
;;

let char (c : char) : char parser = satisfy (fun x -> x = c)
let lower : char parser = satisfy (fun x -> 'a' <= x && x <= 'z')
let upper : char parser = satisfy (fun x -> 'A' <= x && x <= 'Z')
let digit : char parser = satisfy (fun x -> '0' <= x && x <= '9')

(** [p <|> q] runs [p] and returns the result if succeeds. If [p]
   fails then the input will be reset and [q] will run instead. *)
let ( <|> ) (p1 : 'a parser) (p2 : 'a parser) : 'a parser =
  { run =
      (fun input ->
        let input', result = p1.run input in
        match result with
        | Ok x -> input', Ok x
        | Error _ -> p2.run input)
  }
;;

(** [choice ps] runs each parser in [ps] in order until one succeeds
   and returns that result. In the case that none of the parser
   succeeds, then the parser will fail.*)
let choice (ps : 'a parser list) : 'a parser =
  List.fold_right ( <|> ) ps (fail "choice failed")
;;

let letter = lower <|> upper
let alphanum = letter <|> digit

let take_while (f : char -> bool) : string parser =
  { run =
      (fun input ->
        let n = String.length input.text in
        let i = ref 0 in
        while !i < n && f (String.get input.text !i) do
          incr i
        done;
        consume_input input !i (n - !i), Ok (String.sub input.text 0 !i))
  }
;;

let take_while1 (f : char -> bool) : string parser =
  { run =
      (fun input ->
        let n = String.length input.text in
        let i = ref 0 in
        while !i < n && f (String.get input.text !i) do
          incr i
        done;
        if n < 1 || !i < 1
        then input, Error "take_while1 takes at least one"
        else consume_input input !i (n - !i), Ok (String.sub input.text 0 !i))
  }
;;

(** [p >>| f] creates a parser that will run [p], and if it succeeds
   with result [v], will return [f v] *)
let ( >>| ) m f = m >>= fun x -> return (f x)

let ( <$> ) f m = m >>| f
let ( <*> ) f m = f >>= fun f -> m >>| f

(** [p *> q] runs [p], discards its result and then run [q], and
   return its result. *)
let ( *> ) p1 p2 = p1 >>= fun _ -> p2

(** [p <* q] runs [p], then runs [q], discards its result, and returns
   the result of [p]. *)
let ( <* ) p1 p2 = p1 >>= fun x -> p2 >>| fun _ -> x

(** The [liftn] family of functions promote functions to the parser
   monad. For any of these functions, the following equivalence holds:
   [liftn f p1 ... pn = f <$> p1 <*> ... <*> pn ].  *)
let lift = ( >>| )

let lift2 f m1 m2 = f <$> m1 <*> m2
let lift3 f m1 m2 m3 = f <$> m1 <*> m2 <*> m3
let lift4 f m1 m2 m3 m4 = f <$> m1 <*> m2 <*> m3 <*> m4

(** [fix f] computes the fixpoint of [f] and runs the resultant
   parser. The argument that [f] receives is the result of [fix f],
   which [f] must use, paradoxically, to define [fix f].

   [fix] is useful when constructing parsers for inductively-defined
   types such as sequences, trees, etc. Consider for example the
   implementation of the [many] combinator:

{[let many p = fix (fun m -> ((List.cons <$> p <*> m) <|> return [])]}

   [many p] is a parser that will run [p] zero or more times,
   accumulating the result of every run into a list, returning the
   result. It's defined by passing [fix] a function. This function
   assumes its argument [m] is a parser that behaves exactly like
   [many p]. You can see this in the expression comprising the
   left-hand side of the alternative operator [<|>]. This expression
   runs the parser [p] followed by the parser [m], and after which the
   result of [p] is cons'd onto the list that [m] produces. The
   right-hand side of the alternative operator provides a base case
   for the combinator: if [p] fails and the parse connot proceed,
   return an empty list.

   Another way to illustrate the uses of [fix] is to construct a JSON
   parser. Assuming that parsers exist for the basic types such as
   [false], [true], [null], strings, and numbers, the question then
   becomes how to define a parser for objects and arrays? Both contain
   values that are themselves JSON values, so it seems as though it's
   impossible to write a parser that will accept JSON objects and
   arrays before writing a parser for JSON values as a whole.  This is
   the exact situation that [fix] was made for. By defining the
   parsers for arrays and objects within the function that you pass to
   [fix], you will gain access to a parser that you can use to parse
   JSON values, the very parser you are defining!

{[let json =
    fix (fun json ->
        let arr = char '[' *> sep_by (char ',') json <* char ']' in
        let obj = char '{' *> ... json ... <* char '}' in
        choice [str; num; arr json; ...]
      )
]}
 *)
let fix (f : 'a parser -> 'a parser) : 'a parser =
  let rec p = lazy (f r)
  and r = { run = (fun input -> (Lazy.force p).run input) } in
  r
;;

let many p = fix (fun m -> List.cons <$> p <*> m <|> return [])
let pair p = lift2 (fun e1 e2 -> e1, e2) p p

let parse_string p str =
  match p.run (input_of str) with
  | _, Ok x -> Ok x
  | _, Error err -> Error err
;;

(** Example of expr *)

let parens p = char '(' *> p <* char ')'
let add = char '+' *> return ( + )
let sub = char '-' *> return ( - )
let mul = char '*' *> return ( * )
let div = char '/' *> return ( / )

let integer =
  take_while1 (function
    | '0' .. '9' -> true
    | _ -> false)
  >>| int_of_string
;;

let chainl1 e op =
  let rec go acc = lift2 (fun f x -> f acc x) op e >>= go <|> return acc in
  e >>= fun init -> go init
;;

(**
   Arithmetic expression parser.
   EXPR := TERM + TERM
         | TERM - TERM
         | TERM
   TERM := FACTOR * FACTOR
         | FACTOR / FACTOR
         | FACTOR
   FACTOR := ( EXPR )
           | INTEGER
*)
let expr : int parser =
  fix (fun expr ->
    let factor = parens expr <|> integer in
    let term = chainl1 factor (mul <|> div) in
    chainl1 term (add <|> sub))
;;

let eval s =
  match parse_string expr s with
  | Ok v -> v
  | Error msg -> failwith msg
;;

(** Example of boolean expression *)
type expr =
  | Variable of int
  | And of expr * expr
  | Or of expr * expr
  | Xor of expr * expr
  | Neg of expr

let var_of x = Variable x
let and_of x y = And (x, y)
let or_of x y = Or (x, y)
let xor_of x y = Xor (x, y)
let neg_of x = Neg x
let parenthized p = char '(' *> p <* char ')'

(* parsers *)
let id = ref (-1)

let get_id () =
  incr id;
  !id
;;

let reset_id () = id := -1

let var ~occur =
  lower
  >>| fun var ->
  match Hashtbl.find_opt occur var with
  | Some id -> var_of id
  | None ->
    let id = get_id () in
    Hashtbl.add occur var id;
    var_of id
;;

let and_ = char '&' *> return and_of
let or_ = char '|' *> return or_of
let xor = char '^' *> return xor_of
let neg p = char '~' *> (p >>| neg_of)

(**
   Precedence: ~ > & > ^ > |
            not > and > xor > or
   Boolean expression parser.
   EXPR := FA or FA
         | EXPR
   FA := FB xor FB
       | FA
   FB := FC and FC
       | FB
   FB := FACTOR
   FACTOR := VAR
         | ( EXPR )
         | not FACTOR
*)
let expr ~occur : expr parser =
  fix (fun (expr : expr parser) ->
    let factor = fix (fun factor -> neg factor <|> parens expr <|> var ~occur) in
    let fb = chainl1 factor and_ in
    let fb = chainl1 fb xor in
    let fa = chainl1 fb or_ in
    fa)
;;

let remove_blanks s = Seq.filter (fun c -> c <> ' ') (String.to_seq s) |> String.of_seq

let get_exprs s =
  let occur = Hashtbl.create 26 in
  reset_id ();
  let s = remove_blanks s in
  match (pair (expr ~occur)).run (input_of s) with
  | _, Ok r -> r, Hashtbl.length occur
  | _, Error msg -> failwith msg
;;

let eval ~f exp =
  let rec aux = function
    | Variable x -> f x
    | Or (e1, e2) -> aux e1 || aux e2
    | And (e1, e2) -> aux e1 && aux e2
    | Xor (e1, e2) ->
      let v1 = aux e1 in
      let v2 = aux e2 in
      ((not v1) && v2) || (v1 && not v2)
    | Neg e -> not (aux e)
  in
  aux exp
;;

let check e1 e2 n =
  let f x = n land (1 lsl x) = 0 in
  let v1 = eval ~f e1 in
  let v2 = eval ~f e2 in
  v1 = v2
;;

let my_for : int -> int -> int -> (int -> 'a) -> 'a list =
 fun st ed step func ->
  let rec inner st l =
    if st >= ed
    then List.rev l
    else (
      let v = func st in
      inner (st + step) (v :: l))
  in
  inner st []
;;

let solve s case =
  let (e1, e2), total = get_exprs s in
  let res =
    List.for_all
      (fun n ->
        let v1 = eval e1 ~f:(fun m -> n land (1 lsl m) = 0) in
        let v2 = eval e2 ~f:(fun m -> n land (1 lsl m) = 0) in
        v1 = v2)
      (my_for 0 (1 lsl total) 1 (fun n -> n))
  in
  Printf.printf "Data set %d: %s\n" case (if res then "Equivalent" else "Different")
;;

let main () =
  let total_case = read_int () in
  for case = 1 to total_case do
    let input = read_line () in
    solve input case
  done
;;

let () = main ()

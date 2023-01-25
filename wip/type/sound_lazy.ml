(** The language: lambda-calculus with let *)

type varname = string

type exp =
  | Var of varname
  | App of exp * exp
  | Lam of varname * exp
  | Let of varname * exp * exp

(** The types to infer.

    Types without quantified variables are simple types; those containing
    quantified variables are type schemas. A quantified variable is a TVar whose
    level is generic_level.

    Since quantifiers are always on the outside in the HM system, they are
    implied and not explicitly represented.

    Unlike sound_eager, all types, not only type variables, have levels.
    Normally, the level of a composite type is an upper bound on the levels of
    its components. If a type belongs to a region n, all its subcomponents
    should be alive when the region n is still alive. However, levels are
    determined incrementally. Therefore, composite types have two levels:

    - level_old is always an upper bound for the levels of the components
    - level_new is equal or less than level_old.

    If level_new is less than level_old, the type is being promoted to a higher
    region. The type needed to be traversed and all of its components adjusted
    so their levels do not exceed level_new. Generalization will perform such an
    adjustment of levels for some types.

    During type traversals, level_new may have the value marked_level to signify
    that the type is being traversed. Encountering a type at the marked_level
    during the traversals means that we detect a cycle, created during
    unification without the occurs check. *)

type level = int

(** as in OCaml typing/btype.ml *)
let generic_level = 100_000_000

(** for marking a node, to check for cycles. *)
let marked_level = -1

type typ = TVar of tv ref | TArrow of typ * typ * levels
and tv = Unbound of string * level | Link of typ
and levels = { mutable level_old : level; mutable level_new : level }

(** Chase the links of bound variables, returning either a free variable or a
    constructed type. OCaml's typing/btype.ml has the same function with the
    same name. Unlike OCaml, we do path compression.

    This is almost the same implementation of find function in disjoint set. *)
let rec repr : typ -> typ = function
  | TVar ({ contents = Link t } as tvr) ->
      let t = repr t in
      tvr := Link t;
      t
  | t -> t


(** Get the level of a normalized type, which is not a bound TVar. *)
let get_level : typ -> level = function
  | TVar { contents = Unbound (_, l) } -> l
  | TArrow (_, _, ls) -> ls.level_new
  | _ -> assert false


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

let new_arrow t1 t2 =
  TArrow (t1, t2, { level_new = !current_level; level_old = !current_level })


(** Delayed occurs check. We do not do the occurs check when unifying a free
    type variable. Therefore, we may construct a cyclic type. The following
    function, executed only at the end of the type checking, checks for no
    cycles in the type. Incidentally, OCaml does allow cycles in the type: types
    are generally (equi-)recursive in OCaml. *)
let rec cycle_free = function
  | TVar { contents = Unbound _ } -> ()
  | TVar { contents = Link t } -> cycle_free t
  | TArrow (_, _, ls) when ls.level_new = marked_level ->
      failwith "occurs check"
  | TArrow (t1, t2, ls) ->
      let level = ls.level_new in
      ls.level_new <- marked_level;
      cycle_free t1;
      cycle_free t2;
      ls.level_new <- level


(** Main unification. Quantified variables are unexpected: they should've been
    instantiated. The occurs check is lazy; therefore, cycles could be created
    accidentally. We have to watch for them.

    Update the level of the type so that it does not exceed the given level l.

    Invariant: a level of a type can only decrease (assigning the type
    generic_level is special, and does not count as the update). The existing
    level of the type cannot be generic_level (quantified variables must be
    specially instantiated) or marked_level (in which case, we encounter a
    cycle). If the type to update is composite and its new and old levels where
    the same and the new level is updated to a smaller level, the whole type is
    put into the to_be_level_adjusted queue for later traversal and adjustment
    of the levels of components. This work queue to_be_level_adjusted is akin to
    the list of assignments from the old generation to the new generation
    maintained by a generational garbage collector (such as the one in OCaml).
    The update_level itself takes constant time. *)

let to_be_level_adjusted = ref []
let reset_level_adjustment () = to_be_level_adjusted := []

let update_level lv = function
  | TVar ({ contents = Unbound (n, lv') } as tvr) ->
      assert (not (lv' = generic_level));
      if lv < lv' then tvr := Unbound (n, lv)
  | TArrow (_, _, lvs) as t ->
      assert (not (lvs.level_new = generic_level));
      if lvs.level_new = marked_level then failwith "occurs check";
      if lv < lvs.level_new then (
        if lvs.level_new = lvs.level_old then
          to_be_level_adjusted := t :: !to_be_level_adjusted;
        lvs.level_new <- lv)
  | _ -> assert false


(** Unifying a free variable tv with a type t takes constant time: it merely
    links tv to t (setting the level of t to tv if tv's level was smaller).
    Therefore, cycles may be created accidentally, and the complete update of
    type levels may have to be done at a later time.

    Incidentally, another unification may need to traverse the type with the
    pending level update. That unification will do the level update along the
    way.*)

let rec unify t1 t2 : unit =
  if t1 == t2 then ()
  else
    match (repr t1, repr t2) with
    | ( (TVar ({ contents = Unbound (_, l1) } as tv1) as t1),
        (TVar ({ contents = Unbound (_, l2) } as tv2) as t2) ) ->
        (* bind the higher-level var*)
        if l1 > l2 then tv1 := Link t2 else tv2 := Link t1
    | TVar ({ contents = Unbound (_, l) } as tv), t'
    | t', TVar ({ contents = Unbound (_, l) } as tv) ->
        update_level l t';
        tv := Link t'
    | TArrow (tl1, tl2, ll), TArrow (tr1, tr2, lr) ->
        if ll.level_new = marked_level || lr.level_new = marked_level then
          failwith "cycle: occurs check";
        let min_level = min ll.level_new lr.level_new in
        ll.level_new <- marked_level;
        lr.level_new <- marked_level;
        unify_lev min_level tl1 tr1;
        unify_lev min_level tl2 tr2;
        ll.level_new <- min_level;
        lr.level_new <- min_level
    | _ -> failwith "unification error"


and unify_lev l t1 t2 =
  let t1 = repr t1 in
  update_level l t1;
  unify t1 t2


type env = (varname * typ) list

(** Sound generalization: generalize (convert to quantified vars) only those
    free TVars whose level is greater than the current. These TVars belong to
    dead regions. A quantified var is a TVar at the generic_level. We traverse
    only those parts of the type that may contain type variables at the level
    greater than the current. If a type has the level of the current or smaller,
    all of its components have the level not exceeding the current -- and so
    that type does not have to be traversed. After generalization, a constructed
    type receives the generic_level if at least one of its components is
    quantified.

    However, before generalization we must perform the pending level updates.
    After all, a pending update may decrease the level of a type variable
    (promote it to a wider region) and thus save the variable from
    quantification. We do not need to do all of the pending updates: only those
    that deal with types whose level_old > current_level. If level_old <=
    current_level, the type contains no generalizable type variables anyway. *)

let force_delayed_adjustments () =
  let rec loop acc level t =
    match repr t with
    | TVar ({ contents = Unbound (name, l) } as tvr) when l > level ->
        tvr := Unbound (name, level);
        acc
    | TArrow (_, _, ls) when ls.level_new = marked_level ->
        failwith "occurs check"
    | TArrow (_, _, ls) as ty ->
        if ls.level_new > level then ls.level_new <- level;
        adjust_one acc ty
    | _ -> acc
  (* only deals with composite types *)
  and adjust_one acc = function
    | TArrow (_, _, ls) as ty when ls.level_old <= !current_level ->
        ty :: acc (* update later *)
    | TArrow (_, _, ls) when ls.level_old = ls.level_new ->
        acc (* already updated *)
    | TArrow (t1, t2, ls) ->
        let level = ls.level_new in
        ls.level_new <- marked_level;
        let acc = loop acc level t1 in
        let acc = loop acc level t2 in
        ls.level_new <- level;
        ls.level_old <- level;
        acc
    | _ -> assert false
  in
  to_be_level_adjusted := List.fold_left adjust_one [] !to_be_level_adjusted


let gen t =
  force_delayed_adjustments ();
  let rec loop t =
    match repr t with
    | TVar ({ contents = Unbound (name, l) } as tvr) when l > !current_level ->
        tvr := Unbound (name, generic_level)
    | TArrow (t1, t2, ls) when ls.level_new > !current_level ->
        let t1 = repr t1 in
        let t2 = repr t2 in
        loop t1;
        loop t2;
        let l = max (get_level t1) (get_level t2) in
        ls.level_old <- l;
        ls.level_old <- l
    | _ -> ()
  in
  loop t


(** Instantiation: replace schematic variables with fresh TVars. Only the
    components at generic_level are traversed, since only those may contain
    quantified type variables. *)
let inst : typ -> typ =
  let rec loop subst = function
    | TVar { contents = Unbound (name, l) } when l = generic_level -> (
        try (List.assoc name subst, subst)
        with Not_found ->
          let tv = newvar () in
          (tv, (name, tv) :: subst))
    | TVar { contents = Link t } -> loop subst t
    | TArrow (t1, t2, ls) when ls.level_new = generic_level ->
        let t1, subst = loop subst t1 in
        let t2, subst = loop subst t2 in
        (new_arrow t1 t2, subst)
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
      new_arrow ty_x ty_e
  | App (e1, e2) ->
      let ty_fun = typeof env e1 in
      let ty_arg = typeof env e2 in
      let ty_res = newvar () in
      unify ty_fun (new_arrow ty_arg ty_res);
      ty_res
  | Let (x, e, e2) ->
      enter_level ();
      let ty_e = typeof env e in
      leave_level ();
      gen ty_e;
      typeof ((x, ty_e) :: env) e2


let top_type_check : exp -> typ =
 fun exp ->
  reset_type_variables ();
  reset_level_adjustment ();
  let ty = typeof [] exp in
  cycle_free ty;
  ty

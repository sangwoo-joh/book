type name = Name of string | Int of int

type constant = { name : name; constr : bool; arity : int }

type var = string

type expr =
  | Var of var
  | Const of constant
  | Fun of var * expr
  | App of expr * expr
  | Let of var * expr * expr

(** auxiliary functions to build constants *)

let plus = Const { name = Name "+"; arity = 2; constr = false }

let times = Const { name = Name "*"; arity = 2; constr = false }

let int n = Const { name = Int n; arity = 0; constr = true }

(** sample program *)

let sample_expr =
  let plus_x n = App (App (plus, Var "x"), n) in
  App
    ( Fun ("x", App (App (times, plus_x (int 1)), plus_x (int (-1)))),
      App (Fun ("x", App (App (plus, Var "x"), int 1)), int 2) )

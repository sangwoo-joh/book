exception Undefined_constant of string

let type_of_const c =
  let int3 = tarrow tint (tarrow tint tint) in
  match c.name with
  | Int _ -> tint
  | Name ("+" | "*") -> int3
  | Name n -> raise (Undefined_constant n)

exception Free_variable of var

let type_of_var tenv x =
  try List.assoc x tenv with Not_found -> raise (Free_variable x)

let extend tenv (x, t) = (x, t) :: tenv

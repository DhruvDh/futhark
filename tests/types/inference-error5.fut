-- A type parameter cannot be inferred as a specific type.
-- ==
-- error: Types do not match

let f 't (x: i32): t = x

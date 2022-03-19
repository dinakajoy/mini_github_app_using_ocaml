open Brr

val set_date: unit -> unit

val display_text : string -> unit

val display_element : El.t list -> unit

val post_data: string -> string -> Jstr.t option Fut.t
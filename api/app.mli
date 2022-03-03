module Store: Irmin_git.S

val store_repo:string -> string Lwt.t
(** This store_repo allows to store a git repository *)

val schema:unit -> unit Graphql_lwt.Schema.schema Lwt.t
(** This schema allows to query and modify a git repository *)
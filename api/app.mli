module Store: Irmin_git.S
module Sync = Irmin_git

val store_repo:Store.key -> string -> unit Lwt.t
(** This store_repo allows to store a git repository *)

val schema:string -> unit Graphql_lwt.Schema.schema Lwt.t
(** This schema allows to query and modify a git repository *)
module Store: Irmin_git.S

val repo : unit -> Store.repo Lwt.t
(** Initialise the repository for storing the Github repo *)

val sync : Store.repo -> string -> string Lwt.t
(** [sync repo url] syncs the repository at [url] with the local store. *)

val schema : Store.repo -> unit Graphql_lwt.Schema.schema Lwt.t
(** This schema allows to query and modify a git repository. *)
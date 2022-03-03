open Lwt.Syntax
(* open Sys *)
(* open Lwt.Infix *)

(* Irmin store with string contents *)
module Store = Irmin_unix.Git.FS.KV (Irmin.Contents.String)

(* module Sync = Irmin.Sync.Make (Store) *)
module Sync = Irmin.Sync (Store)

module Config = struct
  (* type info = Store.info *)

  let remote = None

  let info = Irmin_unix.info
end

module Gql = Irmin_graphql.Server.Make (Cohttp_lwt_unix.Server) (Config) (Store)

let store_location = "./repos"

let config = Irmin_git.config ~bare:true store_location

(* There must only exist a single repository that we manipulate in order for
   Grahpql schema to work. *)
let repo () = Store.Repo.v config

let check_status = 
  Dream.log "Sync status: %a" (Fmt.result ~ok:Sync.pp_status ~error:Sync.pp_pull_error)

(* Here we clear the underlying git store in preparation for a [Sync.pull], this ensures
   the repository is empty before the pull otherwise if a different remote is given it will
   not work. *)
let clear_repo () =
  let* store = Store.Git.v (Fpath.v store_location) in
    match store with
    | Ok t -> 
      let* status = Store.Git.reset t in
      Dream.log "Reset status: %a" (Fmt.result ~ok:(Fmt.any "success") ~error:Store.Git.pp_error) status;
      Lwt.return_unit
    | Error err -> 
      Dream.log "Store error: %a" Store.Git.pp_error err;
      failwith "err"

(* Syncing resets the repository and pulls in the new data from the specified remote. *)
let sync repo data = 
  let* () = clear_repo () in
  let* t = Store.master repo in
  let remote = Store.remote data in
  let* status = Sync.pull t remote `Set in
  check_status status;
  let+ readme = Store.get t [ "README.md" ] in
  Printf.printf "%s\n%!" readme;
  "Done"

let schema repo =
  Lwt.return @@ Gql.schema repo
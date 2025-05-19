open Lwt.Syntax

(* Irmin store with string contents *)
module Store = Irmin_git_unix.FS.KV (Irmin.Contents.String)

(* Module to synchronize local store with remote store *)
module Sync = Irmin.Sync.Make (Store)

module Config = struct
  type info =  Sync.info
  let remote = None

  let info = Irmin_unix.info
end

module Graphql_Server = Irmin_graphql.Server.Make (Cohttp_lwt_unix.Server) (Config) (Store)

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
let sync repo path = 
  let* () = clear_repo () in
  let* t = Store.main repo in
  let* remote = Store.remote path in
  let* status = Sync.pull t remote `Set in
  check_status status;
  let+ readme = Store.get t [ "README.md" ] in
  Printf.printf "%s\n%!" readme;
  "Done"

(* To test why sync is not working *)
let info = Irmin_git_unix.info
let path2 = "git@github.com:dinakajoy/finance-tracker-app.git"

let test () =
  let config2 = Irmin_git.config ~bare:true store_location in
  let* repo2= Store.Repo.v config2 in
  let* remote = Store.remote path2 in
  let* t =  Store.main repo2 in
  let* _ = Sync.pull_exn t remote `Set in
  let* readme = Store.get t [ "README.md" ] in
  let* tree = Store.get_tree t [] in
  let* tree = Store.Tree.add tree [ "BAR.md" ] "Hoho!" in
  let* tree = Store.Tree.add tree [ "FOO.md" ] "Hihi!" in
  let+ () = Store.set_tree_exn t ~info:(info "merge") [] tree in
  Printf.printf "%s\n%!" readme

let schema repo =
  Lwt.return @@ Graphql_Server.schema repo

let () = Lwt_main.run (test ())
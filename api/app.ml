open Lwt.Syntax

module Config = struct
  let remote = None
  let info = Irmin_unix.info
end

(* Irmin store with string contents *)
module Store = Irmin_unix.Git.FS.KV (Irmin.Contents.String)

module Sync = Irmin.Sync(Store)

module Gql = Irmin_graphql.Server.Make (Cohttp_lwt_unix.Server) (Config) (Store)

(* Commit information *)
(* let info = Irmin_unix.info *)

let config = Irmin_git.config ~bare:true "./repos" 

let store_repo data = 
  let* repo = Store.Repo.v config in
  let remote = Store.remote data in 
  let* t = Store.master repo in
  let* _ = Sync.pull_exn t remote `Set in
  let+ readme = Store.get t [ "README.md" ] in
  Printf.printf "%s\n%!" readme;
  "Done"

  let schema () = 
    let+ repo = Store.Repo.v config in
    Gql.schema repo
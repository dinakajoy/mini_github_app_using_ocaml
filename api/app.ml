open Lwt.Syntax

module Config = struct
  let remote = None
  let info = Irmin_unix.info
end

(* Irmin store with string contents *)
module Store = Irmin_unix.Git.FS.KV (Irmin.Contents.String)

module Sync = Irmin.Sync(Store)

module Gql = Irmin_graphql.Server.Make (Cohttp_lwt_unix.Server) (Config) (Store)

let config = Irmin_git.config "./repos" 

(* let remote = Store.remote "git://github.com/mirage/irmin.git" *)

(* let author = "Test <test@test.com>"
let info fmt = Irmin_unix.info ~author fmt *)

(* Commit information *)
let info = Irmin_unix.info

let store_repo rep =
  let+ repo = Store.Repo.v config in
  let+ t = Store.master repo in
  let remote = Store.remote rep in 
  Sync.pull_exn t remote

let store_repo k v =
  let* repo = Store.Repo.v config in
  let* t = Store.master repo in
  let msg = Fmt.str "Updating /%s" (String.concat "/" k) in
  print_endline msg;
  Store.set_exn t ~info:(info "%s" msg) k v

(* let store_repo k v =
  let* repo = Store.Repo.v config in
  let* t = Store.master repo in
  let msg = Fmt.str "Updating /%s" (String.concat "/" k) in
  print_endline msg;
  Store.set_exn t ~info:(info "%s" msg) k v *)

let schema () = 
  let+ repo = Store.Repo.v config in
  Gql.schema repo

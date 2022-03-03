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

let config = Irmin_git.config ~bare:true "./repos" 

let rec rmrf path = match Sys.is_directory path with
  | true ->
    Sys.readdir path |>
    Array.iter (fun name -> rmrf (Filename.concat path name));
    Unix.rmdir path
  | false -> Sys.remove path

let store_repo data = 
  rmrf "./repos";
  let remote = Store.remote data in 
  let* repo = Store.Repo.v config in
  let* t = Store.master repo in
  let* _ = Sync.pull t remote `Set in 
  let+ readme = Store.get t [ "README.md" ] in
  Printf.printf "%s\n%!" readme;
  "Done"

  let schema () = 
    let+ repo = Store.Repo.v config in
    Gql.schema repo
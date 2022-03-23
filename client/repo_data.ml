open Brr
open Yojson.Basic

let get_string key l =
  match List.assoc key l with `String s -> s | _ -> raise Not_found

let find t path =
  let rec aux j p = match p, j with
    | [], j -> j
    | h::tl, `Assoc o -> aux (List.assoc h o) tl
    | _ -> raise Not_found in
  aux t path

let display_data data text = 
  let span = El.span [El.txt (Jstr.v text)] in 
  match data with
  | `String mydata -> 
    let elem_class = Jstr.v "myclass" in 
    let content = [El.txt (Jstr.v mydata)] in 
    let h2 = El.h2 ~at:At.[class' elem_class] content in 
    let div = El.div ~at:At.[class' (Jstr.v  "wrapper")] [] in
    El.append_children div [span; h2];
    Shared.display_element [div]
  | _ -> 
    let txt = "Error! Expected a string!" in
    let elem_class = Jstr.v "error" in 
    let p_content = [El.txt (Jstr.v txt)] in 
    let p = El.p ~at:At.[class' elem_class] p_content in 
    let div = El.div ~at:At.[class' (Jstr.v  "wrapper")] [] in
    El.append_children div [span; p];
    Shared.display_element [div]

let style_result repo_data = 
  let data = Jstr.to_string repo_data in 
  let json = from_string data in 
  let branches_json = find json [ "data"; "branches" ] in 
  match branches_json with 
  | `List [] -> Shared.display_text "Empty branch(es)!"
  | `List (branch :: _) -> 
    begin
      let date = find branch [ "head"; "info"; "date" ] in 
      display_data date "Date: ";
      let author = find branch [ "head"; "info"; "author" ] in 
      display_data author "Author: ";
      let message = find branch [ "head"; "info"; "message" ] in 
      display_data message "Message: "
    end
  | _ -> Shared.display_text "Error! Expected a list and got something else"

let style_result2 repo_data =
  let data = Jstr.to_string repo_data in 
  let json = from_string data in
  let readme = find json [ "data"; "master"; "tree"; "get_contents"; "value" ] in
  match readme with 
  | `String s -> 
    let elem_class = Jstr.v "readme" in 
    let p_content = [El.txt (Jstr.v s)] in 
    let p = El.p ~at:At.[class' elem_class] p_content in 
    Shared.display_element [p]
  | _ -> Shared.display_text "There was an error"

let format_result data = 
  match data with
  | Some data -> 
    style_result data;
    style_result2 data
  | None -> Shared.display_text "There was an error"

let repo_query = 
  let query = {|
    {
      branches {
        name
        head {
          info {
            date
            author
            message
          }
        }
      }
      master {
        tree {
          get_contents(key: "README.md") {
            key
            metadata
            value
            hash
          }
        }
      }
    }
  |}
  in
  Yojson.Safe.to_string (`Assoc [ "query", `String query ])

let branches () = 
  Shared.display_text "";
  let url = "http://localhost:8080/graphql" in 
  let result = Shared.post_data url repo_query in 
  Fut.await result format_result

let () =
  Shared.set_date ();
  branches ()

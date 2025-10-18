open Brr
open Yojson.Basic
open Omd

(* let get_string key l =
  match List.assoc key l with `String s -> s | _ -> raise Not_found *)

let find t path =
  let rec aux j p = match p, j with
    | [], j -> j
    | h::tl, `Assoc o -> aux (List.assoc h o) tl
    | _ -> raise Not_found in
  aux t path

  let format_date (timestamp : int) : string =
    (* Convert to milliseconds *)
    let ms = float_of_int timestamp *. 1000. in
    let date = Jv.new' (Jv.get Jv.global "Date") [| Jv.of_float ms |] in
  
    (* Get full month name *)
    let month = Jv.to_string (
      Jv.call date "toLocaleString" [|
        Jv.of_string "en-US";
        Jv.obj [| ("month", Jv.of_string "long") |]
      |]
    ) in
  
    let day = Jv.to_int (Jv.call date "getDate" [||]) in
    let year = Jv.to_int (Jv.call date "getFullYear" [||]) in
  
    (* Get time part in 12-hour format with AM/PM *)
    let time = Jv.to_string (
      Jv.call date "toLocaleTimeString" [|
        Jv.of_string "en-US";
        Jv.obj [|
          ("hour", Jv.of_string "numeric");
          ("minute", Jv.of_string "2-digit");
          ("second", Jv.of_string "2-digit");
          ("hour12", Jv.of_bool true)
        |]
      |]
    ) in
  
    Printf.sprintf "%d %s, %d at %s" day month year time

let display_data data text = 
  let label_span = El.span ~at:At.[class' (Jstr.v  "meta-label")] [El.txt (Jstr.v text)] in 
  let div = El.div ~at:At.[class' (Jstr.v  "meta-item")] [] in
  match data with
  | `String mydata -> 
    let content = [El.txt (Jstr.v mydata)] in 
    let value_span = El.span ~at:At.[class' (Jstr.v  "meta-value")] content in 
    El.append_children div [label_span; value_span];
    div
  | _ -> 
    let txt = "Error! Expected a string!" in
    let elem_class = Jstr.v "error" in 
    let p_content = [El.txt (Jstr.v txt)] in 
    let p = El.p ~at:At.[class' elem_class] p_content in 
    El.append_children div [label_span; p];
    div

let style_result repo_data = 
  let meta_wrapper = El.div ~at:At.[class' (Jstr.v  "repo-meta")] [] in
  let meta_header= El.h2 [El.txt (Jstr.v "Last Commit")] in
  El.append_children meta_wrapper [meta_header];
  let data = Jstr.to_string repo_data in 
  let json = from_string data in 
  let branches_json = find json [ "data"; "branches" ] in 
  match branches_json with 
  | `List [] -> Shared.display_text "Empty branch(es)!"
  | `List (branch :: _) -> 
    begin
      let date = find branch [ "head"; "info"; "date" ] in 
      let timestamp = Yojson.Basic.Util.to_string date in
      let human_date = format_date (int_of_string timestamp) in
      let date_elem = display_data (`String human_date) "Date: " in
      let author = find branch [ "head"; "info"; "author" ] in 
      let author_elem = display_data author "Author: " in
      let message = find branch [ "head"; "info"; "message" ] in 
      let commit_elem = display_data message "Message: " in 
      El.append_children meta_wrapper [date_elem; author_elem; commit_elem];
      Shared.display_element [meta_wrapper]
    end
  | _ -> Shared.display_text "Error! Expected a list and got something else"

let style_result2 repo_data =
  let data = Jstr.to_string repo_data in 
  let json = from_string data in
  let readme = find json [ "data"; "main"; "tree"; "get_contents"; "value" ] in
  match readme with 
  | `String s -> 
    let readme_to_html = to_html (of_string s) in
    let div = El.div [] in
    El.set_class (Jstr.v "readme") true div;
    let () = El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v readme_to_html) div in
    Shared.display_element [div]
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
    main {
      tree {
        get_contents(path:"/README.md") {
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

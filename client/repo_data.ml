open Brr
open Ezjsonm

type package = {
  branch : string; 
  date : string
  }

let get_string key l =
  match List.assoc key l with `String s -> s | _ -> raise Not_found

    (* let p_class = Jstr.v "myclass" in 
      let branch = get_string "name" data in 
      let p1 = [El.txt (Jstr.v branch)] in 
      let p1 = El.h1 ~at:At.[class' p_class] p1 in 
      Shared.display_element [p1];
      Console.log ["p1", p1]
      let date = get_string "date" data in 
      let p2 = [El.txt (Jstr.v date)] in 
      let p2 = El.h1 ~at:At.[class' p_class] p2 in 
      Shared.display_element [p2];
      Console.log ["p2", p2];
      let author = get_string "author" data in 
      let p3 = [El.txt (Jstr.v author)] in 
      let p3 = El.h1 ~at:At.[class' p_class] p3 in 
      Shared.display_element [p3];
      Console.log ["p3", p3];
      let message = get_string "message" data in 
      let p4 = [El.txt (Jstr.v message)] in 
      let p4 = El.h1 ~at:At.[class' p_class] p4 in 
      Shared.display_element [p4];
      Console.log ["p4", p4] *)

(* let display_pkgs { branch; date } = 
  let p_class = Jstr.v "myclass" in 
  let p1 = [El.txt (Jstr.v branch)] in 
  let p1 = El.h1 ~at:At.[class' p_class] p1 in 
  Shared.display_element [p1];
  Console.log ["p1", p1];
  let p2 = [El.txt (Jstr.v date)] in 
  let p2 = El.h1 ~at:At.[class' p_class] p2 in 
  Shared.display_element [p2];
  Console.log ["p2", p2] *)

let func l = 
  match l with 
  | `O d -> Console.log ["d", d]
  | `String d -> Console.log ["d", d]
  | _ -> Console.log [ "None", l ]

let style_result repo_data =
  let data = Jstr.to_string repo_data in 
  let json = from_string data in
  let json = find json [ "data"; "branches" ] in 
  match json with 
  | json -> func json;
    Console.log [ "data", data ]
  | _ -> Console.log [ "None" ]

(* {
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
} *)

let format_result data = 
  match data with
  | Some data -> style_result data
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
  Ezjsonm.value_to_string (`O [ "query", `String query ])

let branches () = 
  Shared.display_text "";
  let url = "http://localhost:8080/graphql" in 
  let result = Shared.post_data url repo_query in 
  Fut.await result format_result

let () =
  Shared.set_date ();
  branches ()

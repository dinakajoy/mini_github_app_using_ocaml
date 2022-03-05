open Js_of_ocaml
open Brr
open Brr_io
open Fut.Syntax

let post_data url query =
  let req_url = Jstr.of_string url in 
  let req_query = Jstr.of_string query in 
  let init =
    Fetch.Request.init
      ~method':(Jstr.of_string "POST")
      ~body:(Fetch.Body.of_jstr req_query)
      ~headers:
        (Fetch.Headers.of_assoc
           [ Jstr.of_string "Content-Type", Jstr.of_string "application/json" ])
      ()
  in
  let* res = Fetch.url ~init req_url in
  match res with
  | Ok response ->
    (let* result = Fetch.Body.json (Fetch.Response.as_body response) in
    match result with
    | Ok _ ->
      Console.log [ Jstr.of_string "SUCCESS2" ];
      Fut.return "SUCCESS2"
    | Error _ ->
      Console.error [ Jstr.of_string "ERROR2" ];
      Fut.return  "ERROR2")
  | Error _ ->
    Console.error [ Jstr.of_string "ERROR1" ];
    Fut.return  "ERROR1"

let get_repo_data url body = 
  let req_body = Jstr.to_string (Jstr.lowercased (Jstr.of_string body)) in
  let* data = post_data url req_body in
  Fut.return (data)

let display_result result = 
  let result_element =  (Document.find_el_by_id G.document) (Jstr.v "result") in
  match result_element with
  | Some v ->  El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v result) v;
  | None -> ()

let save_repo repo =
  let url = "http://localhost:8080/repo" in
  let res = Fut.await (get_repo_data url repo) in 
  (* if res == "Done"
    then display_result "Please paste in a valid git repository"
  else display_result "Sorry, there was an error" *)
  Console.log ["res", res ]

let get_set_repo _ = 
  let input =  (Document.find_el_by_id G.document) (Jstr.v "input") in
  match input with
  | Some element -> 
    let data = Jstr.to_string (El.prop El.Prop.value element) in
    if data == "" 
      then display_result "Please paste in a valid git repository"
    else save_repo data
  | None -> ()
  
let set_date () = 
  let date_span =  (Document.find_el_by_id G.document) (Jstr.v "date") in
  match date_span with
  | Some v ->  El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v "2022") v;
  | None -> ()

let () =
  set_date ();
  let submit =  (Document.find_el_by_id G.document) (Jstr.v "submit") in
  match submit with
  | Some el ->  Ev.listen Ev.click get_set_repo (El.as_target el)
  | None -> ()

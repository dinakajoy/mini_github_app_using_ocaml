open Brr
open Brr_io
open Fut.Syntax

let display_result result = 
  let result_element =  (Document.find_el_by_id G.document) (Jstr.v "result") in
  match result_element with
  | Some v ->  El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v result) v
  | None -> ()

let format_result data = 
  match data with
  | Some _ -> Window.set_location G.window (Uri.v (Jstr.v "/repo-data"))
  | None -> display_result "There was an error"

let get_response_data response =
  let* data = Fetch.Body.json (Fetch.Response.as_body response) in
  match data with
  | Ok response -> Fut.return (Some response)
  | Error e -> 
    Console.error [ "error", e ];
    Fut.return None

let post_data url req_query =
  let req_url = Jstr.of_string url in 
  let req_query = Jstr.of_string req_query in 
  let init =
    Fetch.Request.init
      ~method':(Jstr.of_string "POST")
      ~body:(Fetch.Body.of_jstr req_query)
      ~headers:
        (Fetch.Headers.of_assoc
           [ Jstr.of_string "Content-Type", Jstr.of_string "application/json" ])
      ()
  in
  let* result = Fetch.url ~init req_url in
  match result with
  | Ok response -> get_response_data response
  | Error e -> 
    Console.log["e", e];
    Fut.return None
  
let save_repo req_body =
  display_result "";
  let url = "http://localhost:8080/repo" in
  let req_body = Jstr.to_string (Jstr.lowercased (Jstr.of_string req_body)) in
  post_data url req_body

let set_repo _ = 
  let input =  (Document.find_el_by_id G.document) (Jstr.v "input") in
  match input with
  | Some element -> 
    let users_repo = Jstr.to_string (El.prop El.Prop.value element) in
    if (Jstr.is_empty (Jstr.of_string users_repo)) 
      then display_result "Please paste in a valid git repository"
    else 
      let result = save_repo users_repo in
      Fut.await result format_result;
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
  | Some el ->  Ev.listen Ev.click set_repo (El.as_target el);
  | None -> ()

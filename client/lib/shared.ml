open Brr
open Brr_io
open Fut.Syntax

let set_date () = 
  let date_span =  (Document.find_el_by_id G.document) (Jstr.v "date") in
  match date_span with
  | Some v ->  El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v "2022") v;
  | None -> ()

let display_text result = 
  let result_element =  (Document.find_el_by_id G.document) (Jstr.v "result") in
  match result_element with
  | Some v -> El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v result) v
  | None -> ()

let display_element result = 
  let result_element =  (Document.find_el_by_id G.document) (Jstr.v "result") in
  match result_element with
  | Some v -> El.append_children v result
  | None -> ()

let get_response_data response =
  let* data = Fetch.Body.text (Fetch.Response.as_body response) in
  match data with
  | Ok response -> Fut.return (Some response)
  | Error error -> 
    Console.error [ Jstr.v "Error!", Jv.Error.message error ];
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
  | Error error -> 
    Console.error [ Jstr.v "Err!", Jv.Error.message error ];
    Fut.return None
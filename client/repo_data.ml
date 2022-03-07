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
  | Some data -> 
    Console.log[data]
  | None -> display_result "There was an error"

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
  let* result = Fetch.url ~init req_url in
  match result with
  | Ok response -> 
    (let* data = Fetch.Body.json (Fetch.Response.as_body response) in
    match data with
    | Ok response -> Fut.return (Some response)
    | Error _ -> Fut.return None)
  | Error _ -> Fut.return None

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
  |}
  in
  Ezjsonm.value_to_string (`O [ "query", `String query ])

let branches () = 
  display_result "";
  let url = "http://localhost:8080/graphql" in 
  let result = post_data url repo_query in
  Fut.await result format_result
   
let set_date () = 
  let date_span =  (Document.find_el_by_id G.document) (Jstr.v "date") in
  match date_span with
  | Some v ->  El.set_prop (El.Prop.jstr (Jstr.v "innerHTML")) (Jstr.v "2022") v;
  | None -> ()

let () =
  set_date ();
  branches ()

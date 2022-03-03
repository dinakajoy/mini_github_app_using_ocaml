open Js_of_ocaml
(* open Lwt.Syntax *)
open Brr
open Brr_io
open Fut.Syntax

(* let send_repo_query repo =
  let query = {|
    {
      repository(name: "|} ^ repo ^ {|") {
        name
      }
    }
  |}
  in
  Ezjsonm.value_to_string (`O [ "query", `String query ]) *)

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

let branches = 
  let div = Dom_html.(createDiv document) in
  div##.innerHTML := Js.string "Test";
  let result_element =  Dom_html.getElementById_exn "result" in
  Dom.appendChild result_element div
  
let save_repo repo =
  let url = "http://localhost:8080/repo" in
  let res = get_repo_data url repo in 
  Console.log ["res", Fut.await res ]

let () =
  let date_span =  Dom_html.getElementById_exn "date" in
  date_span##.innerHTML := Js.string ("2021");
  let main = Dom_html.getElementById_exn "input" in
  let input = Dom_html.(createInput document) in
  input##.onkeyup := Dom_html.handler (fun v ->
    Js.Opt.iter v##.target (fun t ->
      Js.Opt.iter (Dom_html.CoerceTo.input t) (fun i ->
        save_repo (Js.to_string i##.value))
    );
    Js._true);
  Dom.appendChild main input
  
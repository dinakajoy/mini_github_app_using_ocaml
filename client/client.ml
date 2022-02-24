open Js_of_ocaml
(* open Lwt.Syntax
open Brr
open Brr_io
open Fut.Syntax *)

(* let repo_query repo =
  let query = {|
    {
      repository(name: "|} ^ repo ^ {|") {
        name
      }
    }
  |}
  in
  Ezjsonm.value_to_string (`O [ "query", `String query ])

let get_repo_stat url query =
  let init =
    Fetch.Request.init
      ~method':(Jstr.of_string "POST")
      ~body:(Fetch.Body.of_jstr (Jstr.of_string query))
      ~headers:
        (Fetch.Headers.of_assoc
           [ Jstr.of_string "Content-Type", Jstr.of_string "application/json" ])
      ()
  in
  let* result = Fetch.url ~init (Jstr.of_string url) in
  match result with
  | Ok response ->
    (* get_packages_response_data response *)
    Console.log [ Jstr.of_string "SUCCESS" ];
    Fut.return (Some "Yeeeee")
  | Error _ ->
    Console.error [ Jstr.of_string "ERROR" ];
    Fut.return None

let format_repo_data data = ()

let get_repo_data repo =
  let url = "http://localhost:8080/graphql" in
  let query = repo_query repo in
  let result = get_repo_stat url query in
  Fut.await format_repo_data result *)

let () =
  let date_span =  Dom_html.getElementById_exn "date" in
  date_span##.innerHTML := Js.string ("2021")
  (* let main = Dom_html.getElementById_exn "main" in
  let input = Dom_html.(createInput document) in
  input##.onkeyup := Dom_html.handler (fun v ->
    Js.Opt.iter v##.target (fun t ->
      Js.Opt.iter (Dom_html.CoerceTo.input t) (fun i ->
        get_repo_data (Js.to_string i##.value))
    );
    Js._true); *)
  (* Dom.appendChild main input; *)
  
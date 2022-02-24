open Lwt.Syntax

(* type message_object = {
  message : string;
} [@@deriving yojson] *)

let home =
  <html>
    <body id="body">
    <header>Mini Github</header>
      <main id="main"></main>
      </footer>&copy; <span id="date"></span></footer>
      <script src="/static/client.js"></script>
      <script></script></footer>
    </body>
  </html>

let main () =
  let* schema = App.schema "https://github.com/mirage/irmin" in
  Dream.serve
  @@ Dream.logger
  @@ Dream.origin_referer_check
  @@ Dream.router [
    Dream.get "/" (fun _ -> Dream.html home);

    Dream.get "/repo" (fun request ->
      let%lwt body = Dream.body request in
      (* let message_object =
        body *)
        (* |> Yojson.Safe.from_string *)
        (* |> message_object_of_yojson *)
      in
      App.store_repo body
    );

    Dream.any "/graphql" (Dream.graphql (fun _ -> Lwt.return ()) schema);
    Dream.get "/graphiql" (Dream.graphiql "/graphql");

    Dream.get "/static/**" (Dream.static "./static");
  ]
  @@ Dream.not_found

let () = Lwt_main.run (main ())

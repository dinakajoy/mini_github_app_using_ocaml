open Lwt.Syntax

let home =
  <html>
    <head><link rel="stylesheet" href="/static/style.css"></head>
    <body id="body">
      <header class="header">Mini Github</header>
      <main class="main">
        <p>Please paste in a git repository below: </p>
        <div id="input" class="input"></div>
        <div id="result" class="result"></div>
      </main>
      <footer  class="footer">&copy; <span id="date"></span></footer>
      <script src="/static/client.js"></script>
    </body>
  </html>

let main () =
  let* repo = App.repo () in
  let* schema = App.schema repo in 
  Dream.serve 
  @@ Dream.logger 
  (* @@ Dream.origin_referer_check *)
  @@ Dream.router [
    Dream.get "/" (fun _ -> Dream.html home);

    Dream.post "/repo" (fun request ->
      let* body = Dream.body request in 
      let+ res = App.sync repo body in
      (Dream.response res));

    Dream.any "/graphql" (Dream.graphql (fun _ -> Lwt.return ()) schema);
    Dream.get "/graphiql" (Dream.graphiql "/graphql");

    Dream.get "/static/**" (Dream.static "./static");
  ]
  @@ Dream.not_found

let () = Lwt_main.run (main ())

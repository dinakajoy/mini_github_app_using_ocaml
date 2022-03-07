open Lwt.Syntax

let home =
  <html>
    <head><link rel="stylesheet" href="/static/style.css"></head>
    <body id="body">
      <header class="header">Mini Github</header>
      <main class="main">
        <p>Please paste in a git repository below: </p>
        <div class="input">
          <input type="text" id="input" />
          <button type="submit" id="submit">Submit</button>
        </div>
        <div id="result" class="result"></div>
      </main>
      <footer  class="footer">&copy; <span id="date"></span></footer>
      <script src="/static/client.js"></script>
    </body>
  </html>

let repo_result =
  <html>
    <head><link rel="stylesheet" href="/static/style.css"></head>
    <body id="body">
      <header class="header">Mini Github</header>
      <main class="main">
        <div><a href="/">Go Home</a></div>
        <div id="result" class="result"></div>
      </main>
      <footer  class="footer">&copy; <span id="date"></span></footer>
      <script src="/static/repo_data.js"></script>
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

    Dream.get "/repo-data" (fun _ -> Dream.html repo_result);

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

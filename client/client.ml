open Brr

let submit_btn = (Document.find_el_by_id G.document) (Jstr.v "submit")

let format_result data = 
  match data with
  | Some _ -> Window.set_location G.window (Uri.v (Jstr.v "http://localhost:8080/repo-data"))
  | None -> Shared.display_text "There was an error"

let save_repo req_body =
  Shared.display_text "";
  let url = "http://localhost:8080/repo" in
  let req_body = Jstr.to_string (Jstr.lowercased (Jstr.of_string req_body)) in
  Shared.post_data url req_body

let set_repo _ = 
  let input =  (Document.find_el_by_id G.document) (Jstr.v "input") in
  match input with
  | Some element -> 
    let users_repo = Jstr.to_string (El.prop El.Prop.value element) in
    if (Jstr.is_empty (Jstr.of_string users_repo)) 
      then Shared.display_text "Please paste in a valid git repository"
    else 
      let result = save_repo users_repo in
      Fut.await result format_result;
  | None -> ()
  
let () =
  Shared.set_date ();
  let submit =  submit_btn in
  match submit with
  | Some el ->  Ev.listen Ev.click set_repo (El.as_target el);
  | None -> ()

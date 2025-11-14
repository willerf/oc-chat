open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
module Protocol = Oc_chat_common.Protocol
module Types = Oc_chat_common.Types
module Rpc_effect = Bonsai_web.Rpc_effect

let server_url = "ws://localhost:8000/rpc"
let _ = ignore server_url

module Page = struct
  type t =
    | Landing
    | SignUp
    | Login
    | UserHome
    | Conversation
  [@@deriving sexp, equal, compare, enumerate]
end

let landing_component ~set_page =
  let%arr set_page = set_page in
  Vdom.Node.div
    [ Vdom.Node.h1 [ Vdom.Node.text "Web Chat" ]
    ; Vdom.Node.button
        ~attrs:[ Vdom.Attr.on_click (fun _ -> set_page Page.Login) ]
        [ Vdom.Node.text "Login" ]
    ; Vdom.Node.button
        ~attrs:[ Vdom.Attr.on_click (fun _ -> set_page Page.SignUp) ]
        [ Vdom.Node.text "Sign Up" ]
    ]
;;

let sign_up_component ~set_page =
  let%sub user_id, set_user_id = Bonsai.state (module Types.User_id) ~default_model:"" in
  let%sub user_password, set_user_password =
    Bonsai.state (module Types.User_password) ~default_model:""
  in
  let%sub error_message, set_error_message =
    Bonsai.state (module String) ~default_model:""
  in
  let%sub sign_up_rpc =
    Rpc_effect.Rpc.dispatcher
      Protocol.Sign_up.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
  in
  let%arr set_page = set_page
  and user_id = user_id
  and set_user_id = set_user_id
  and user_password = user_password
  and set_user_password = set_user_password
  and error_message = error_message
  and set_error_message = set_error_message
  and sign_up_rpc = sign_up_rpc in
  Vdom.Node.div
    [ Vdom.Node.h1 [ Vdom.Node.text "Sign Up" ]
    ; Vdom.Node.input
        ~attrs:
          [ Vdom.Attr.type_ "text"
          ; Vdom.Attr.placeholder "Enter User ID"
          ; Vdom.Attr.value_prop user_id
          ; Vdom.Attr.on_input (fun _ new_value -> set_user_id new_value)
          ]
        ()
    ; Vdom.Node.input
        ~attrs:
          [ Vdom.Attr.type_ "text"
          ; Vdom.Attr.placeholder "Enter User Password"
          ; Vdom.Attr.value_prop user_password
          ; Vdom.Attr.on_input (fun _ new_value -> set_user_password new_value)
          ]
        ()
    ; Vdom.Node.button
        ~attrs:
          [ Vdom.Attr.on_click (fun _ ->
              let query : Protocol.Sign_up.Query.t = { user_id; user_password } in
              Ui_effect.bind (sign_up_rpc query) ~f:(function
                | Ok (Ok _) ->
                  Ui_effect.all_unit [ set_error_message ""; set_page Page.Landing ]
                | Error error | Ok (Error error) ->
                  set_error_message (Error.to_string_hum error)))
          ]
        [ Vdom.Node.text "Sign Up" ]
    ; Vdom.Node.text error_message
    ]
;;

let login_component ~set_page ~set_user =
  let%sub user_id, set_user_id = Bonsai.state (module Types.User_id) ~default_model:"" in
  let%sub user_password, set_user_password =
    Bonsai.state (module Types.User_password) ~default_model:""
  in
  let%sub error_message, set_error_message =
    Bonsai.state (module String) ~default_model:""
  in
  let%sub login_rpc =
    Rpc_effect.Rpc.dispatcher
      Protocol.Login.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
  in
  let%arr set_page = set_page
  and set_user = set_user
  and user_id = user_id
  and set_user_id = set_user_id
  and user_password = user_password
  and set_user_password = set_user_password
  and error_message = error_message
  and set_error_message = set_error_message
  and login_rpc = login_rpc in
  Vdom.Node.div
    [ Vdom.Node.h1 [ Vdom.Node.text "Login" ]
    ; Vdom.Node.input
        ~attrs:
          [ Vdom.Attr.type_ "text"
          ; Vdom.Attr.placeholder "Enter User ID"
          ; Vdom.Attr.value_prop user_id
          ; Vdom.Attr.on_input (fun _ new_value -> set_user_id new_value)
          ]
        ()
    ; Vdom.Node.input
        ~attrs:
          [ Vdom.Attr.type_ "text"
          ; Vdom.Attr.placeholder "Enter User Password"
          ; Vdom.Attr.value_prop user_password
          ; Vdom.Attr.on_input (fun _ new_value -> set_user_password new_value)
          ]
        ()
    ; Vdom.Node.button
        ~attrs:
          [ Vdom.Attr.on_click (fun _ ->
              let query : Protocol.Login.Query.t = { user_id; user_password } in
              Ui_effect.bind (login_rpc query) ~f:(function
                | Ok (Ok user) ->
                  Ui_effect.all_unit
                    [ set_error_message ""; set_user user; set_page Page.UserHome ]
                | Error error | Ok (Error error) ->
                  set_error_message (Error.to_string_hum error)))
          ]
        [ Vdom.Node.text "Login" ]
    ; Vdom.Node.text error_message
    ]
;;

let user_home_component ~set_page ~set_view_conversation ~(user : Types.User.t Value.t) =
  let%sub new_conversation, set_new_conversation =
    Bonsai.state (module Types.Conversation_id) ~default_model:""
  in
  let%sub error_message, set_error_message =
    Bonsai.state (module String) ~default_model:""
  in
  let%sub create_conversation_rpc =
    Rpc_effect.Rpc.dispatcher
      Protocol.Create_conversation.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
  in
  let%arr set_page = set_page
  and set_view_conversation = set_view_conversation
  and user = user
  and new_conversation = new_conversation
  and set_new_conversation = set_new_conversation
  and error_message = error_message
  and set_error_message = set_error_message
  and create_conversation_rpc = create_conversation_rpc in
  Vdom.Node.div
    ([ Vdom.Node.h1 [ Vdom.Node.text "User Home" ]
     ; Vdom.Node.input
         ~attrs:
           [ Vdom.Attr.type_ "text"
           ; Vdom.Attr.placeholder "Enter new conversation ID"
           ; Vdom.Attr.value_prop new_conversation
           ; Vdom.Attr.on_input (fun _ new_value -> set_new_conversation new_value)
           ]
         ()
     ; Vdom.Node.button
         ~attrs:
           [ Vdom.Attr.on_click (fun _ ->
               let query =
                 { Protocol.Create_conversation.Query.user_id = user.user_id
                 ; conversation_id = new_conversation
                 }
               in
               Ui_effect.bind (create_conversation_rpc query) ~f:(function
                 | Ok (Ok _) ->
                   Ui_effect.all_unit
                     [ set_error_message ""
                     ; set_view_conversation new_conversation
                     ; set_page Page.Conversation
                     ]
                 | Error error | Ok (Error error) ->
                   set_error_message (Error.to_string_hum error)))
           ]
         [ Vdom.Node.text "Create Conversation" ]
     ; Vdom.Node.text error_message
     ; Vdom.Node.h1 [ Vdom.Node.text "Select a conversation below!" ]
     ]
     @ List.map user.conversations ~f:(fun conversation_id ->
       Vdom.Node.button
         ~attrs:
           [ Vdom.Attr.on_click (fun _ ->
               Ui_effect.all_unit
                 [ set_view_conversation conversation_id; set_page Page.Conversation ])
           ]
         [ Vdom.Node.text conversation_id ]))
;;

let conversation_component
      ~set_page
      ~(view_conversation : Types.Conversation_id.t Value.t)
      ~(user : Types.User.t Value.t)
  =
  let%sub message, set_message = Bonsai.state (module String) ~default_model:"" in
  let%sub new_user, set_new_user =
    Bonsai.state (module Types.Conversation_id) ~default_model:""
  in
  let%sub error_message, set_error_message =
    Bonsai.state (module String) ~default_model:""
  in
  let%sub add_conversation_user_rpc =
    Rpc_effect.Rpc.dispatcher
      Protocol.Add_conversation_user.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
  in
  let%sub conversation_rpc =
    Rpc_effect.Polling_state_rpc.poll
      (module Protocol.Get_conversation.Query)
      (module Protocol.Get_conversation.Diffable)
      ~clear_when_deactivated:true
      Protocol.Get_conversation.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
      ~every:(Time_ns.Span.of_sec 0.1)
      view_conversation
  in
  let%sub send_message_rpc =
    Rpc_effect.Rpc.dispatcher
      Protocol.Send_message.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
  in
  let%arr set_page = set_page
  and view_conversation = view_conversation
  and user = user
  and message = message
  and set_message = set_message
  and new_user = new_user
  and set_new_user = set_new_user
  and error_message = error_message
  and set_error_message = set_error_message
  and conversation_rpc = conversation_rpc
  and send_message_rpc = send_message_rpc
  and add_conversation_user_rpc = add_conversation_user_rpc in
  Vdom.Node.div
    [ Vdom.Node.h1 [ Vdom.Node.text "Conversation" ]
    ; Vdom.Node.button
        ~attrs:[ Vdom.Attr.on_click (fun _ -> set_page Page.UserHome) ]
        [ Vdom.Node.text "Back" ]
    ; Vdom.Node.input
        ~attrs:
          [ Vdom.Attr.type_ "text"
          ; Vdom.Attr.placeholder "Enter user ID"
          ; Vdom.Attr.value_prop new_user
          ; Vdom.Attr.on_input (fun _ new_value -> set_new_user new_value)
          ]
        ()
    ; Vdom.Node.button
        ~attrs:
          [ Vdom.Attr.on_click (fun _ ->
              let query =
                { Protocol.Add_conversation_user.Query.user_id = new_user
                ; conversation_id = view_conversation
                }
              in
              Ui_effect.bind (add_conversation_user_rpc query) ~f:(function
                | Ok (Ok _) -> set_error_message ""
                | Error error | Ok (Error error) ->
                  Ui_effect.all_unit
                    [ set_error_message (Error.to_string_hum error); set_new_user "" ]))
          ]
        [ Vdom.Node.text "Add User" ]
    ; Vdom.Node.text error_message
    ; Vdom.Node.div
        [ Vdom.Node.input
            ~attrs:
              [ Vdom.Attr.type_ "text"
              ; Vdom.Attr.placeholder "Type a message"
              ; Vdom.Attr.value_prop message
              ; Vdom.Attr.on_input (fun _ new_value -> set_message new_value)
              ]
            ()
        ; Vdom.Node.button
            ~attrs:
              [ Vdom.Attr.on_click (fun _ ->
                  let query : Protocol.Send_message.Query.t =
                    { conversation_id = view_conversation
                    ; message = { user_id = user.user_id; text = message }
                    }
                  in
                  let send_effect = send_message_rpc query |> Effect.ignore_m in
                  Effect.Many [ send_effect; set_message "" ])
              ]
            [ Vdom.Node.text "Send" ]
        ]
    ; Vdom.Node.div
        (match conversation_rpc.last_ok_response with
         | None -> [ Vdom.Node.text "No messages..." ]
         | Some (_, conversation) ->
           List.map conversation.messages ~f:(fun msg ->
             Vdom.Node.div [ Vdom.Node.text (msg.user_id ^ ": " ^ msg.text) ]))
    ]
;;

let app =
  let%sub page, set_page = Bonsai.state (module Page) ~default_model:Page.Landing in
  let default_user =
    { Types.User.Stable.V1.user_id = "Error User ID"
    ; user_password = "Error User Password"
    ; conversations = []
    }
  in
  let%sub user, set_user = Bonsai.state (module Types.User) ~default_model:default_user in
  let%sub view_conversation, set_view_conversation =
    Bonsai.state (module Types.Conversation_id) ~default_model:""
  in
  Bonsai.enum
    (module Page)
    ~match_:page
    ~with_:(function
      | Landing -> landing_component ~set_page
      | SignUp -> sign_up_component ~set_page
      | Login -> login_component ~set_page ~set_user
      | UserHome -> user_home_component ~set_page ~set_view_conversation ~user
      | Conversation -> conversation_component ~set_page ~view_conversation ~user)
;;

let () = Bonsai_web.Start.start app ~bind_to_element_with_id:"app"

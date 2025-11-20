open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
module Protocol = Oc_chat_common.Protocol
module Types = Oc_chat_common.Types
module Rpc_effect = Bonsai_web.Rpc_effect

let server_url = "ws://localhost:8000/rpc"

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
  let open Vdom in
  Node.div
    ~attrs:[ Attr.classes [ "page-root"; "home-root" ] ]
    [ Node.div
        ~attrs:[ Attr.class_ "card" ]
        [ Node.h1
            ~attrs:[ Attr.classes [ "card-title"; "home-title" ] ]
            [ Node.text "Web Chat" ]
        ; Node.p
            ~attrs:[ Attr.class_ "card-subtitle" ]
            [ Node.text "A lightweight chat space for quick conversations." ]
        ; Node.div
            ~attrs:[ Attr.classes [ "btn-row"; "home-buttons" ] ]
            [ Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-primary" ]
                  ; Attr.on_click (fun _ -> set_page Page.Login)
                  ]
                [ Node.text "Log In" ]
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-secondary" ]
                  ; Attr.on_click (fun _ -> set_page Page.SignUp)
                  ]
                [ Node.text "Create Account" ]
            ]
        ]
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
  let open Vdom in
  Node.div
    ~attrs:[ Attr.classes [ "page-root"; "signup-root" ] ]
    [ Node.div
        ~attrs:[ Attr.classes [ "card"; "signup-card" ] ]
        [ Node.h1
            ~attrs:[ Attr.classes [ "card-title"; "signup-title" ] ]
            [ Node.text "Create an account" ]
        ; Node.p
            ~attrs:[ Attr.class_ "card-subtitle" ]
            [ Node.text "Pick credentials to start chatting with friends." ]
        ; Node.div
            ~attrs:[ Attr.classes [ "form-stack"; "signup-form" ] ]
            [ Node.input
                ~attrs:
                  [ Attr.classes [ "input"; "signup-input" ]
                  ; Attr.type_ "text"
                  ; Attr.placeholder "Username"
                  ; Attr.value_prop user_id
                  ; Attr.on_input (fun _ new_value -> set_user_id new_value)
                  ]
                ()
            ; Node.input
                ~attrs:
                  [ Attr.classes [ "input"; "signup-input" ]
                  ; Attr.type_ "password"
                  ; Attr.placeholder "Password"
                  ; Attr.value_prop user_password
                  ; Attr.on_input (fun _ new_value -> set_user_password new_value)
                  ]
                ()
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-primary"; "signup-button" ]
                  ; Attr.on_click (fun _ ->
                      let query : Protocol.Sign_up.Query.t = { user_id; user_password } in
                      Ui_effect.bind (sign_up_rpc query) ~f:(function
                        | Ok Ok ->
                          Ui_effect.all_unit
                            [ set_error_message ""; set_page Page.Landing ]
                        | Ok Username_taken -> set_error_message "Username taken"
                        | Error error -> set_error_message (Error.to_string_hum error)))
                  ]
                [ Node.text "Sign Up" ]
            ]
        ; Node.div
            ~attrs:[ Attr.classes [ "error-text"; "signup-error" ] ]
            [ Node.text error_message ]
        ; Node.div
            ~attrs:[ Attr.class_ "btn-row" ]
            [ Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-secondary" ]
                  ; Attr.on_click (fun _ -> set_page Page.Landing)
                  ]
                [ Node.text "Back" ]
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-ghost" ]
                  ; Attr.on_click (fun _ -> set_page Page.Login)
                  ]
                [ Node.text "Already have an account?" ]
            ]
        ]
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
  let open Vdom in
  Node.div
    ~attrs:[ Attr.class_ "page-root" ]
    [ Node.div
        ~attrs:[ Attr.class_ "card" ]
        [ Node.h1 ~attrs:[ Attr.class_ "card-title" ] [ Node.text "Welcome back" ]
        ; Node.p
            ~attrs:[ Attr.class_ "card-subtitle" ]
            [ Node.text "Sign in to see your conversations." ]
        ; Node.div
            ~attrs:[ Attr.class_ "form-stack" ]
            [ Node.input
                ~attrs:
                  [ Attr.class_ "input"
                  ; Attr.type_ "text"
                  ; Attr.placeholder "Username"
                  ; Attr.value_prop user_id
                  ; Attr.on_input (fun _ new_value -> set_user_id new_value)
                  ]
                ()
            ; Node.input
                ~attrs:
                  [ Attr.class_ "input"
                  ; Attr.type_ "password"
                  ; Attr.placeholder "Password"
                  ; Attr.value_prop user_password
                  ; Attr.on_input (fun _ new_value -> set_user_password new_value)
                  ]
                ()
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-primary" ]
                  ; Attr.on_click (fun _ ->
                      let query : Protocol.Login.Query.t = { user_id; user_password } in
                      Ui_effect.bind (login_rpc query) ~f:(function
                        | Ok (Ok user) ->
                          Ui_effect.all_unit
                            [ set_error_message ""
                            ; set_user user
                            ; set_page Page.UserHome
                            ]
                        | Ok Unknown_username -> set_error_message "Unknown username"
                        | Ok Incorrect_password -> set_error_message "Incorrect password"
                        | Error error -> set_error_message (Error.to_string_hum error)))
                  ]
                [ Node.text "Log In" ]
            ]
        ; Node.div ~attrs:[ Attr.class_ "error-text" ] [ Node.text error_message ]
        ; Node.div
            ~attrs:[ Attr.class_ "btn-row" ]
            [ Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-secondary" ]
                  ; Attr.on_click (fun _ -> set_page Page.SignUp)
                  ]
                [ Node.text "Create account" ]
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-ghost" ]
                  ; Attr.on_click (fun _ -> set_page Page.Landing)
                  ]
                [ Node.text "Back" ]
            ]
        ]
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
  let user_id = Value.map user ~f:(fun user -> user.user_id) in
  let%sub user_conversations_rpc =
    Rpc_effect.Polling_state_rpc.poll
      (module Protocol.Get_conversations.Query.Stable.V1)
      (module Protocol.Get_conversations.Diffable.Stable.V1)
      ~clear_when_deactivated:true
      Protocol.Get_conversations.rpc
      ~where_to_connect:(Rpc_effect.Where_to_connect.Url server_url)
      ~every:(Time_ns.Span.of_sec 0.1)
      user_id
  in
  let%arr set_page = set_page
  and set_view_conversation = set_view_conversation
  and user = user
  and new_conversation = new_conversation
  and set_new_conversation = set_new_conversation
  and error_message = error_message
  and set_error_message = set_error_message
  and create_conversation_rpc = create_conversation_rpc
  and user_conversations_rpc = user_conversations_rpc in
  let open Vdom in
  let conversation_list =
    match user_conversations_rpc.last_ok_response with
    | None ->
      Node.p
        ~attrs:[ Attr.class_ "section-subtext" ]
        [ Node.text "Loading your conversations..." ]
    | Some (_, []) ->
      Node.p
        ~attrs:[ Attr.class_ "section-subtext" ]
        [ Node.text "No conversations yet. Create one above to get started." ]
    | Some (_, conversations) ->
      Node.div
        ~attrs:[ Attr.class_ "conversation-list" ]
        (List.map conversations ~f:(fun conversation_id ->
           Node.button
             ~attrs:
               [ Attr.classes [ "btn"; "btn-secondary" ]
               ; Attr.on_click (fun _ ->
                   Ui_effect.all_unit
                     [ set_view_conversation conversation_id; set_page Page.Conversation ])
               ]
             [ Node.text conversation_id ]))
  in
  Node.div
    ~attrs:[ Attr.classes [ "page-root"; "dashboard-root" ] ]
    [ Node.div
        ~attrs:[ Attr.classes [ "card"; "wide" ] ]
        [ Node.h1
            ~attrs:[ Attr.class_ "card-title" ]
            [ Node.text ("Hi, " ^ user.user_id ^ "!") ]
        ; Node.p
            ~attrs:[ Attr.class_ "card-subtitle" ]
            [ Node.text "Create a new room or jump into an existing one." ]
        ; Node.div
            ~attrs:[ Attr.class_ "form-stack" ]
            [ Node.p
                ~attrs:[ Attr.class_ "section-title" ]
                [ Node.text "New conversation" ]
            ; Node.input
                ~attrs:
                  [ Attr.class_ "input"
                  ; Attr.type_ "text"
                  ; Attr.placeholder "Conversation name"
                  ; Attr.value_prop new_conversation
                  ; Attr.on_input (fun _ new_value -> set_new_conversation new_value)
                  ]
                ()
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-primary" ]
                  ; Attr.on_click (fun _ ->
                      let query : Protocol.Create_conversation.Query.t =
                        { user_id = user.user_id; conversation_id = new_conversation }
                      in
                      Ui_effect.bind (create_conversation_rpc query) ~f:(function
                        | Ok Ok ->
                          Ui_effect.all_unit
                            [ set_error_message ""
                            ; set_view_conversation new_conversation
                            ; set_page Page.Conversation
                            ]
                        | Ok Conversation_name_taken ->
                          set_error_message "Conversation name taken"
                        | Error error -> set_error_message (Error.to_string_hum error)))
                  ]
                [ Node.text "Create conversation" ]
            ; Node.div ~attrs:[ Attr.class_ "error-text" ] [ Node.text error_message ]
            ]
        ; Node.div
            [ Node.p
                ~attrs:[ Attr.class_ "section-title" ]
                [ Node.text "Your conversations" ]
            ; conversation_list
            ]
        ]
    ]
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
      (module Protocol.Get_conversation.Query.Stable.V1)
      (module Protocol.Get_conversation.Diffable.Stable.V1)
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
  let open Vdom in
  let message_board_children =
    match conversation_rpc.last_ok_response with
    | None -> [ Node.text "No messages yet..." ]
    | Some (_, conversation) ->
      let ordered_messages = List.rev conversation.messages in
      List.map ordered_messages ~f:(fun msg ->
        Node.div
          ~attrs:[ Attr.class_ "message" ]
          [ Node.div ~attrs:[ Attr.class_ "message-author" ] [ Node.text msg.user_id ]
          ; Node.text msg.text
          ])
  in
  Node.div
    ~attrs:[ Attr.classes [ "page-root"; "conversation-root" ] ]
    [ Node.div
        ~attrs:[ Attr.classes [ "card"; "conversation-card" ] ]
        [ Node.div
            ~attrs:[ Attr.class_ "conversation-header" ]
            [ Node.div
                [ Node.h1
                    ~attrs:[ Attr.class_ "card-title" ]
                    [ Node.text view_conversation ]
                ; Node.p
                    ~attrs:[ Attr.class_ "card-subtitle" ]
                    [ Node.text ("Signed in as " ^ user.user_id) ]
                ]
            ; Node.button
                ~attrs:
                  [ Attr.classes [ "btn"; "btn-secondary" ]
                  ; Attr.on_click (fun _ -> set_page Page.UserHome)
                  ]
                [ Node.text "Back" ]
            ]
        ; Node.div
            [ Node.p ~attrs:[ Attr.class_ "section-title" ] [ Node.text "Invite someone" ]
            ; Node.div
                ~attrs:[ Attr.class_ "inline-form" ]
                [ Node.input
                    ~attrs:
                      [ Attr.class_ "input"
                      ; Attr.type_ "text"
                      ; Attr.placeholder "Username"
                      ; Attr.value_prop new_user
                      ; Attr.on_input (fun _ new_value -> set_new_user new_value)
                      ]
                    ()
                ; Node.button
                    ~attrs:
                      [ Attr.classes [ "btn"; "btn-ghost" ]
                      ; Attr.on_click (fun _ ->
                          let query : Protocol.Add_conversation_user.Query.t =
                            { user_id = new_user; conversation_id = view_conversation }
                          in
                          Ui_effect.bind (add_conversation_user_rpc query) ~f:(function
                            | Ok Ok ->
                              Ui_effect.all_unit [ set_error_message ""; set_new_user "" ]
                            | Ok Unknown_conversation ->
                              set_error_message "Unknown conversation name"
                            | Ok Unknown_user -> set_error_message "Unknown user name"
                            | Error error ->
                              Ui_effect.all_unit
                                [ set_error_message (Error.to_string_hum error)
                                ; set_new_user ""
                                ]))
                      ]
                    [ Node.text "Add user" ]
                ]
            ; Node.div ~attrs:[ Attr.class_ "error-text" ] [ Node.text error_message ]
            ]
        ; Node.div
            [ Node.p ~attrs:[ Attr.class_ "section-title" ] [ Node.text "Messages" ]
            ; Node.div ~attrs:[ Attr.class_ "message-board" ] message_board_children
            ]
        ; Node.div
            [ Node.p ~attrs:[ Attr.class_ "section-title" ] [ Node.text "Send a message" ]
            ; Node.div
                ~attrs:[ Attr.class_ "message-input-row" ]
                [ Node.input
                    ~attrs:
                      [ Attr.class_ "input"
                      ; Attr.type_ "text"
                      ; Attr.placeholder "Type a message"
                      ; Attr.value_prop message
                      ; Attr.on_input (fun _ new_value -> set_message new_value)
                      ]
                    ()
                ; Node.button
                    ~attrs:
                      [ Attr.classes [ "btn"; "btn-primary" ]
                      ; Attr.on_click (fun _ ->
                          let query : Protocol.Send_message.Query.t =
                            { conversation_id = view_conversation
                            ; message = { user_id = user.user_id; text = message }
                            }
                          in
                          let send_effect = send_message_rpc query |> Effect.ignore_m in
                          Effect.Many [ send_effect; set_message "" ])
                      ]
                    [ Node.text "Send" ]
                ]
            ]
        ]
    ]
;;

let app =
  let%sub page, set_page = Bonsai.state (module Page) ~default_model:Page.Landing in
  let default_user : Types.User.t =
    { user_id = "Error Username"; user_password = "Error Password"; conversations = [] }
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

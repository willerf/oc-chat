open! Core
open! Async
module Protocol = Oc_chat_common.Protocol
module Types = Oc_chat_common.Types

let start ~port =
  let state = State.create () in
  let implementations =
    Rpc.Implementations.create_exn
      ~on_unknown_rpc:`Raise
      ~implementations:
        [ Rpc.Rpc.implement Protocol.Sign_up.rpc (fun _ { user_id; user_password } ->
            (match State.mem_user state user_id with
             | true -> Protocol.Sign_up.Response.Username_taken
             | false ->
               let new_user : Types.User.t =
                 { user_id; user_password; conversations = [] }
               in
               State.add_user_exn state new_user;
               Ok)
            |> return)
        ; Rpc.Rpc.implement Protocol.Login.rpc (fun _ { user_id; user_password } ->
            (match State.find_user state user_id with
             | Some user ->
               (match String.equal user.user_password user_password with
                | true -> Protocol.Login.Response.Ok user
                | false -> Incorrect_password)
             | None -> Unknown_username)
            |> return)
        ; Rpc.Rpc.implement
            Protocol.Send_message.rpc
            (fun _ { conversation_id; message } ->
               State.add_message state ~conversation_id ~message |> return)
        ; Polling_state_rpc.implement
            ~on_client_and_server_out_of_sync:print_s
            ~for_first_request:(fun _ conversation_id ->
              return (State.find_conversation_exn state conversation_id))
            Protocol.Get_conversation.rpc
            (fun _ conversation_id ->
               return (State.find_conversation_exn state conversation_id))
          |> Rpc.Implementation.lift ~f:(fun connection_state ->
            connection_state, connection_state)
        ; Rpc.Rpc.implement
            Protocol.Create_conversation.rpc
            (fun _ { conversation_id; user_id } ->
               (match State.mem_conversation state conversation_id with
                | true -> Protocol.Create_conversation.Response.Conversation_name_taken
                | false ->
                  let new_conversation : Types.Conversation.t =
                    { conversation_id; messages = [] }
                  in
                  State.add_conversation_exn state new_conversation;
                  State.add_user_to_conversation state ~user_id ~conversation_id;
                  Ok)
               |> return)
        ; Rpc.Rpc.implement
            Protocol.Add_conversation_user.rpc
            (fun _ { conversation_id; user_id } ->
               let result =
                 match State.mem_conversation state conversation_id with
                 | false -> Protocol.Add_conversation_user.Response.Unknown_conversation
                 | true ->
                   State.add_user_to_conversation state ~user_id ~conversation_id;
                   Ok
               in
               return result)
        ]
  in
  let where_to_listen = Tcp.Where_to_listen.of_port port in
  Rpc_websocket.Rpc.serve
    ~where_to_listen
    ~implementations
    ~initial_connection_state:(fun () _from _addr _conn -> _conn)
    ~should_process_request:(fun _ _ -> Ok ())
    ()
;;

let () =
  let server = start ~port:8000 in
  don't_wait_for (server >>| ignore);
  never_returns (Scheduler.go ())
;;

open! Core
open! Async
module Protocol = Oc_chat_common.Protocol
module Types = Oc_chat_common.Types
module User_map = Map.Make (Types.User_id)
module Conversation_map = Map.Make (Types.Conversation_id)

module State = struct
  type t =
    { mutable users : Types.User.t User_map.t
    ; mutable conversations : Types.Conversation.t Conversation_map.t
    }

  let create () : t = { users = User_map.empty; conversations = Conversation_map.empty }
end

let start ~port =
  let state = State.create () in
  let implementations =
    Rpc.Implementations.create_exn
      ~on_unknown_rpc:`Raise
      ~implementations:
        [ Rpc.Rpc.implement Protocol.Sign_up.rpc (fun _ { user_id; user_password } ->
            let result =
              match Map.mem state.users user_id with
              | true ->
                Or_error.error_string ("Username \"" ^ user_id ^ "\" already taken!")
              | false ->
                let new_user =
                  { Types.User.Stable.V1.user_id; user_password; conversations = [] }
                in
                state.users <- Map.add_exn state.users ~key:user_id ~data:new_user;
                Ok ()
            in
            return result)
        ; Rpc.Rpc.implement Protocol.Login.rpc (fun _ { user_id; user_password } ->
            let result =
              match Map.find state.users user_id with
              | Some user ->
                (match String.equal user.user_password user_password with
                 | true -> Ok user
                 | false -> Or_error.error_string "Incorrect password!")
              | None -> Or_error.error_string "Unknown username!"
            in
            return result)
        ; Rpc.Rpc.implement
            Protocol.Send_message.rpc
            (fun _ { conversation_id; message } ->
               state.conversations
               <- Map.change state.conversations conversation_id ~f:(function
                    | Some conversation ->
                      Some
                        { conversation with messages = message :: conversation.messages }
                    | None -> None);
               return ())
        ; Polling_state_rpc.implement
            ~on_client_and_server_out_of_sync:print_s
            ~for_first_request:(fun _ conversation_id ->
              return (Map.find_exn state.conversations conversation_id))
            Protocol.Get_conversation.rpc
            (fun _ conversation_id ->
               return (Map.find_exn state.conversations conversation_id))
          |> Rpc.Implementation.lift ~f:(fun connection_state ->
            connection_state, connection_state)
        ; Rpc.Rpc.implement
            Protocol.Create_conversation.rpc
            (fun _ { conversation_id; user_id } ->
               let result =
                 match Map.mem state.conversations conversation_id with
                 | true ->
                   Or_error.error_string
                     ("Conversation already exists with conversation ID: "
                      ^ conversation_id)
                 | false ->
                   let new_conversation =
                     { Types.Conversation.Stable.V1.conversation_id; messages = [] }
                   in
                   state.conversations
                   <- Map.add_exn
                        state.conversations
                        ~key:conversation_id
                        ~data:new_conversation;
                   state.users
                   <- Map.change state.users user_id ~f:(function
                        | Some user ->
                          Some
                            { user with
                              conversations = conversation_id :: user.conversations
                            }
                        | None -> None);
                   Ok ()
               in
               return result)
        ; Rpc.Rpc.implement
            Protocol.Add_conversation_user.rpc
            (fun _ { conversation_id; user_id } ->
               let result =
                 match Map.mem state.conversations conversation_id with
                 | false ->
                   Or_error.error_string
                     ("Conversation does not exist for conversation ID: "
                      ^ conversation_id)
                 | true ->
                   state.users
                   <- Map.change state.users user_id ~f:(function
                        | Some user ->
                          (match
                             List.exists
                               user.conversations
                               ~f:(Types.Conversation_id.equal conversation_id)
                           with
                           | false ->
                             Some
                               { user with
                                 conversations = conversation_id :: user.conversations
                               }
                           | true -> Some user)
                        | None -> None);
                   Ok ()
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

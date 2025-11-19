open! Core
module Protocol = Oc_chat_common.Protocol
module Types = Oc_chat_common.Types
module User_map : module type of Map.M (Types.User_id)
module Conversation_map : module type of Map.M (Types.Conversation_id)

type t

val create : unit -> t
val mem_user : t -> Types.User_id.t -> bool
val add_user_exn : t -> Types.User.t -> unit
val find_user : t -> Types.User_id.t -> Types.User.t option
val mem_conversation : t -> Types.Conversation_id.t -> bool
val add_conversation_exn : t -> Types.Conversation.t -> unit
val find_conversation : t -> Types.Conversation_id.t -> Types.Conversation.t option
val find_conversation_exn : t -> Types.Conversation_id.t -> Types.Conversation.t

val add_user_to_conversation
  :  t
  -> user_id:Types.User_id.t
  -> conversation_id:Types.Conversation_id.t
  -> unit

val add_message
  :  t
  -> conversation_id:Types.Conversation_id.t
  -> message:Types.Message.t
  -> unit

open! Core
open! Async
module Protocol = Oc_chat_common.Protocol
module Types = Oc_chat_common.Types
module User_map = Map.M (Types.User_id)
module Conversation_map = Map.M (Types.Conversation_id)

module Persist = struct
  module Stable = struct
    module V1 = struct
      type t =
        { users : (Types.User_id.Stable.V1.t * Types.User.Stable.V1.t) list
        ; conversations :
            (Types.Conversation_id.Stable.V1.t * Types.Conversation.Stable.V1.t) list
        }
      [@@deriving bin_io, sexp]

      let load ~filepath = Reader.load_sexp filepath t_of_sexp
      let write ~filepath ~persist = Writer.save_sexp filepath ([%sexp_of: t] persist)
    end
  end

  type t = Stable.V1.t
end

type t =
  { mutable users : Types.User.t User_map.t
  ; mutable conversations : Types.Conversation.t Conversation_map.t
  }

let create () : t =
  { users = Map.empty (module Types.User_id)
  ; conversations = Map.empty (module Types.Conversation_id)
  }
;;

let mem_user (t : t) = Map.mem t.users

let add_user_exn (t : t) (user : Types.User.t) =
  t.users <- Map.add_exn t.users ~key:user.user_id ~data:user
;;

let find_user (t : t) = Map.find t.users
let find_user_exn (t : t) = Map.find_exn t.users
let mem_conversation (t : t) = Map.mem t.conversations

let add_conversation_exn (t : t) (conversation : Types.Conversation.t) =
  t.conversations
  <- Map.add_exn t.conversations ~key:conversation.conversation_id ~data:conversation
;;

let find_conversation (t : t) = Map.find t.conversations
let find_conversation_exn (t : t) = Map.find_exn t.conversations

let add_user_to_conversation (t : t) ~user_id ~conversation_id =
  t.users
  <- Map.change t.users user_id ~f:(function
       | Some user ->
         if List.mem user.conversations conversation_id ~equal:Types.Conversation_id.equal
         then Some user
         else Some { user with conversations = conversation_id :: user.conversations }
       | None -> None)
;;

let add_message (t : t) ~conversation_id ~message =
  t.conversations
  <- Map.change t.conversations conversation_id ~f:(function
       | Some conversation ->
         Some { conversation with messages = message :: conversation.messages }
       | None -> None)
;;

let to_persist (t : t) : Persist.t =
  { users = Map.to_alist t.users; conversations = Map.to_alist t.conversations }
;;

let of_persist (persist : Persist.t) : t =
  { users = Map.of_alist_exn (module Types.User_id) persist.users
  ; conversations = Map.of_alist_exn (module Types.Conversation_id) persist.conversations
  }
;;

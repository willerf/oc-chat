open! Core
open! Async_kernel
open! Async_rpc_kernel

module Sign_up = struct
  module Query = struct
    type t =
      { user_id : Types.User_id.Stable.V1.t
      ; user_password : Types.User_password.Stable.V1.t
      }
    [@@deriving bin_io]
  end

  module Response = struct
    type t =
      | Ok
      | Username_taken
    [@@deriving bin_io]
  end

  let rpc =
    Rpc.Rpc.create
      ~name:"sign-up"
      ~version:1
      ~bin_query:Query.bin_t
      ~bin_response:Response.bin_t
  ;;
end

module Login = struct
  module Query = struct
    type t =
      { user_id : Types.User_id.Stable.V1.t
      ; user_password : Types.User_password.Stable.V1.t
      }
    [@@deriving bin_io]
  end

  module Response = struct
    type t =
      | Ok of Types.User.Stable.V1.t
      | Unknown_username
      | Incorrect_password
    [@@deriving bin_io]
  end

  let rpc =
    Rpc.Rpc.create
      ~name:"login"
      ~version:1
      ~bin_query:Query.bin_t
      ~bin_response:Response.bin_t
  ;;
end

module Send_message = struct
  module Query = struct
    type t =
      { conversation_id : Types.Conversation_id.Stable.V1.t
      ; message : Types.Message.Stable.V1.t
      }
    [@@deriving bin_io]
  end

  module Response = struct
    type t = unit [@@deriving bin_io]
  end

  let rpc =
    Rpc.Rpc.create
      ~name:"send-message"
      ~version:1
      ~bin_query:Query.bin_t
      ~bin_response:Response.bin_t
  ;;
end

module Get_conversation = struct
  module Query = struct
    type t = Types.Conversation_id.Stable.V1.t [@@deriving bin_io, equal, sexp]
  end

  module Diffable = struct
    module T = struct
      type t = Types.Conversation.Stable.V1.t [@@deriving bin_io, equal, sexp]

      let equal = Types.Conversation.Stable.V1.equal
    end

    include T
    include Diffable.Atomic.Make (T)
  end

  let rpc =
    Polling_state_rpc.create
      ~name:"get-conversation"
      ~version:1
      ~query_equal:Query.equal
      ~bin_query:Query.bin_t
      (module Diffable)
  ;;
end

module Create_conversation = struct
  module Query = struct
    type t =
      { conversation_id : Types.Conversation_id.Stable.V1.t
      ; user_id : Types.User_id.Stable.V1.t
      }
    [@@deriving bin_io]
  end

  module Response = struct
    type t =
      | Ok
      | Conversation_name_taken
    [@@deriving bin_io]
  end

  let rpc =
    Rpc.Rpc.create
      ~name:"create-conversation"
      ~version:1
      ~bin_query:Query.bin_t
      ~bin_response:Response.bin_t
  ;;
end

module Add_conversation_user = struct
  module Query = struct
    type t =
      { conversation_id : Types.Conversation_id.Stable.V1.t
      ; user_id : Types.User_id.Stable.V1.t
      }
    [@@deriving bin_io]
  end

  module Response = struct
    type t =
      | Ok
      | Unknown_conversation
    [@@deriving bin_io]
  end

  let rpc =
    Rpc.Rpc.create
      ~name:"add-conversation-user"
      ~version:1
      ~bin_query:Query.bin_t
      ~bin_response:Response.bin_t
  ;;
end

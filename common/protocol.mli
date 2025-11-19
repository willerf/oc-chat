open! Core
open! Async_kernel
open! Async_rpc_kernel

module Sign_up : sig
  module Query : sig
    module Stable : sig
      module V1 : sig
        type t =
          { user_id : Types.User_id.Stable.V1.t
          ; user_password : Types.User_password.Stable.V1.t
          }
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  module Response : sig
    module Stable : sig
      module V1 : sig
        type t =
          | Ok
          | Username_taken
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  val rpc : (Query.t, Response.t) Rpc.Rpc.t
end

module Login : sig
  module Query : sig
    module Stable : sig
      module V1 : sig
        type t =
          { user_id : Types.User_id.Stable.V1.t
          ; user_password : Types.User_password.Stable.V1.t
          }
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  module Response : sig
    module Stable : sig
      module V1 : sig
        type t =
          | Ok of Types.User.Stable.V1.t
          | Unknown_username
          | Incorrect_password
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  val rpc : (Query.t, Response.t) Rpc.Rpc.t
end

module Send_message : sig
  module Query : sig
    module Stable : sig
      module V1 : sig
        type t =
          { conversation_id : Types.Conversation_id.Stable.V1.t
          ; message : Types.Message.Stable.V1.t
          }
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  module Response : sig
    module Stable : sig
      module V1 : sig
        type t = unit [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  val rpc : (Query.t, Response.t) Rpc.Rpc.t
end

module Get_conversation : sig
  module Query : sig
    module Stable : sig
      module V1 : sig
        type t = Types.Conversation_id.Stable.V1.t [@@deriving bin_io, equal, sexp]
      end
    end

    type t = Stable.V1.t
  end

  module Diffable : sig
    module Stable : sig
      module V1 : sig
        type t = Types.Conversation.Stable.V1.t [@@deriving bin_io, equal, sexp]

        include Polling_state_rpc.Diffable with type t := t
      end
    end

    type t = Stable.V1.t
  end

  val rpc : (Query.t, Diffable.t) Polling_state_rpc.t
end

module Create_conversation : sig
  module Query : sig
    module Stable : sig
      module V1 : sig
        type t =
          { conversation_id : Types.Conversation_id.Stable.V1.t
          ; user_id : Types.User_id.Stable.V1.t
          }
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  module Response : sig
    module Stable : sig
      module V1 : sig
        type t =
          | Ok
          | Conversation_name_taken
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  val rpc : (Query.t, Response.t) Rpc.Rpc.t
end

module Add_conversation_user : sig
  module Query : sig
    module Stable : sig
      module V1 : sig
        type t =
          { conversation_id : Types.Conversation_id.Stable.V1.t
          ; user_id : Types.User_id.Stable.V1.t
          }
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  module Response : sig
    module Stable : sig
      module V1 : sig
        type t =
          | Ok
          | Unknown_conversation
        [@@deriving bin_io]
      end
    end

    type t = Stable.V1.t
  end

  val rpc : (Query.t, Response.t) Rpc.Rpc.t
end

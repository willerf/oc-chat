open! Core

module User_id = struct
  module Stable = struct
    module V1 = struct
      type t = string [@@deriving bin_io, sexp, equal, compare]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal, compare]
end

module User_password = struct
  module Stable = struct
    module V1 = struct
      type t = string [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

module Conversation_id = struct
  module Stable = struct
    module V1 = struct
      type t = string [@@deriving bin_io, sexp, equal, compare]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal, compare]
end

module Message = struct
  module Stable = struct
    module V1 = struct
      type t =
        { user_id : User_id.Stable.V1.t
        ; text : string
        }
      [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

module Conversation = struct
  module Stable = struct
    module V1 = struct
      type t =
        { conversation_id : Conversation_id.Stable.V1.t
        ; messages : Message.Stable.V1.t list
        }
      [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

module User = struct
  module Stable = struct
    module V1 = struct
      type t =
        { user_id : User_id.Stable.V1.t
        ; user_password : User_password.Stable.V1.t
        ; conversations : Conversation_id.Stable.V1.t list
        }
      [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

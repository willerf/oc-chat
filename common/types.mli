module User_id : sig
  module Stable : sig
    module V1 : sig
      type t = string [@@deriving bin_io, sexp, equal, compare]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal, compare]
end

module User_password : sig
  module Stable : sig
    module V1 : sig
      type t = string [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

module Conversation_id : sig
  module Stable : sig
    module V1 : sig
      type t = string [@@deriving bin_io, sexp, equal, compare]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal, compare]
end

module Message : sig
  module Stable : sig
    module V1 : sig
      type t =
        { user_id : User_id.Stable.V1.t
        ; text : string
        }
      [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

module Conversation : sig
  module Stable : sig
    module V1 : sig
      type t =
        { conversation_id : Conversation_id.Stable.V1.t
        ; messages : Message.Stable.V1.t list
        }
      [@@deriving bin_io, sexp, equal]
    end
  end

  type t = Stable.V1.t [@@deriving bin_io, sexp, equal]
end

module User : sig
  module Stable : sig
    module V1 : sig
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

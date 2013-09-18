module DecentExposure
  # Public: A generic expection class for decent_exposure
  class Exception < ::Exception; end

  # Public: An ancestor can't be found
  class UnknownAncestor < Exception; end

  # Public: An expected exposure hasn't been declared
  class MissingExposure < Exception; end
end

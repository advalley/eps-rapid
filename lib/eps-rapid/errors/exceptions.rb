module EpsRapid
  module Exceptions
    class EpsRapidError < StandardError; end
    class BadRequestError < StandardError; end
    class UnauthorizedError < StandardError; end
    class ForbiddenError < StandardError; end
    class NotFoundError < StandardError; end
    class SessionGoneError < StandardError; end
    class UpgradeRequiredError < StandardError; end
    class TooManyRequestsError < StandardError; end
  end
end
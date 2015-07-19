module Actions
  module Foreman
    module Provision

      class ProvisionAction < EntryAction
        middleware.use Middleware::KeepCurrentUser
      end
    end
  end
end

module Actions
  module Foreman
    module Provision

      class HostAction < EntryAction

        def plan(host, args = {})
          plan_self({ host_id: host.id }.merge(args))
        end

        def host
          @host ||= ::Host.find(input[:host_id])
        end

      end
    end
  end
end

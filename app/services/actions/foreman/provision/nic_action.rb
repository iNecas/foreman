module Actions
  module Foreman
    module Provision

      class NicAction < EntryAction

        def plan(nic, args = {})
          plan_self(args.merge(nic_id: nic.id))
        end

        def nic
          @nic ||= ::Nic::Base.find(input[:nic_id])
        end

      end
    end
  end
end

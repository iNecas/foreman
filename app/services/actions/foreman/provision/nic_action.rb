module Actions
  module Foreman
    module Provision

      class NicAction < EntryAction

        def plan(nic)
          plan_self(nic_id: nic.id)
        end

        def nic
          @nic ||= ::Nic::Base.find(input[:nic_id])
        end

      end
    end
  end
end

module Actions
  module Foreman
    module Provision
      module Dhcp
        class Create < NicAction
          def plan(nic,  nic_attrs)
            plan_dhcp_proxy_action(ForemanProxy::Dhcp::Record::Create, nic, nic_attrs: nic_attrs)
          end
        end

        class Destroy < NicAction
          def plan(nic)
            plan_dhcp_proxy_action(ForemanProxy::Dhcp::Record::Destroy, nic)
          end
        end
      end
    end
  end
end

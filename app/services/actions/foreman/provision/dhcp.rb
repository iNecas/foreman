module Actions
  module Foreman
    module Provision
      module Dhcp
        class Create < NicAction
          def plan(nic, nic_attrs)
            plan_action(ForemanProxy::Dhcp::Record::Create,
                        jumpstart: nic.jumpstart?,
                        proxy_url: nic.subnet.dhcp.url,
                        attrs: nic.dhcp_attrs.except(:proxy),
                        nic_attrs: nic_attrs)
          end
        end

        class Destroy < NicAction
          def run
            output[:response] = nic.del_dhcp.inspect
          end
        end
      end
    end
  end
end

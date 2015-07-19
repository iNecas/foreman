module Actions
  module Foreman
    module Provision
      class WaitForSsh < Base
        def plan(host, nics_attrs)
          ssh_nic = host.managed_interfaces.first
          plan_action(WaitForPort, port: 22, nic_attrs: nics_attrs[ssh_nic.id.to_s])
        end
      end
    end
  end
end

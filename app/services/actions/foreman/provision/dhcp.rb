module Actions
  module Foreman
    module Provision
      module Dhcp
        class Create < NicAction
          def run
            output[:response] = nic.set_dhcp.inspect
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

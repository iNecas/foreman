module Actions
  module Foreman
    module Provision
      class SetDhcp < NicAction
        def run
          binding.pry
          output[:response] = nic.set_dhcp.inspect
        end
      end
    end
  end
end

module Actions
  module Foreman
    module Provision
      class ComputePowerUp < HostAction
        def run
          output[:response] = host.setComputePowerUp.inspect
        end
      end
    end
  end
end

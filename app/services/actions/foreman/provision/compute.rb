module Actions
  module Foreman
    module Provision
      module Compute
        class Create < HostAction
          def run
            compute = host.setCompute
            output[:compute] = JSON.load(compute.all_attributes.to_json)
            host.setComputeDetails
            host.save
          end
        end

        class PowerUp < HostAction
          def run
            output[:response] = host.setComputePowerUp.inspect
          end
        end

        class Destroy < HostAction
          def run
            output[:compute] = host.delCompute.inspect
          end
        end
      end
    end
  end
end

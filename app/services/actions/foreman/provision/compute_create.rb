module Actions
  module Foreman
    module Provision
      class ComputeCreate < HostAction
        def run
          compute = host.setCompute
          output[:compute] = JSON.load(compute.all_attributes.to_json)
          host.setComputeDetails
          host.save
        end
      end
    end
  end
end

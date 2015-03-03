module Actions
  module Foreman
    module Provision
      module Compute
        class Create < HostAction
          input_format do
            param :args, Hash
          end

          output_format do
            param :uuid, String
            param :response, Hash
          end

          def plan(host)
            host.add_interfaces_to_compute_attrs
            host.compute_attributes.merge!(:name => Setting[:use_shortname_for_vms] ? host.shortname : host.name)
            host.save
            super(host, args: host.compute_attributes)
          end

          def run
            host.vm = host.compute_resource.create_vm input[:args]
            output[:response] = JSON.load(host.vm.all_attributes.to_json)
            host.setComputeDetails
            output[:uuid] = host.uuid
            host.save
          end
        end

        class PowerUp < HostAction
          input_format do
            param :uuid
            param :response
          end

          def run
            output[:response] = host.compute_resource.start_vm(input[:uuid])
          end
        end

        class Destroy < HostAction
          input_format do
            param :uuid
            param :response
          end

          def plan(host)
            super(host, uuid: host.uuid)
          end

          def run
            output[:response] = host.compute_resource.destroy_vm(input[:uuid])
          end
        end
      end
    end
  end
end

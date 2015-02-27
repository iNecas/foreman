module Actions
  module Foreman
    module Provision
      module Network
        class Create < ProvisionAction
          def plan(host)
            # action_subject(host)
            host.setBuild
            sequence do
              plan_action(Compute::Create, host)
              host.managed_interfaces.each do |nic|
                plan_action(Dhcp::Create, nic)
                plan_action(Tftp::Create, nic)
                plan_action(Tftp::CreateBootFiles, nic)
                plan_action(Dns::CreateARecord, nic)
                plan_action(Dns::CreatePtrRecord, nic)
              end
              plan_action(Compute::PowerUp, host)
            end
          end

        end

        class Finish < ProvisionAction
          def plan(host)
            host.built(true)
            host.interfaces.each do |nic|
              plan_action(Tftp::Create, nic) if nic.tftp?
            end
          end
        end

        class Destroy < ProvisionAction
          def plan(host)
            # action_subject(host)
            sequence do
              host.managed_interfaces.each do |nic|
                plan_action(Dhcp::Destroy, nic)
                plan_action(Tftp::Destroy, nic)
                plan_action(Dns::DestroyARecord, nic)
                plan_action(Dns::DestroyPtrRecord, nic)
              end
              plan_action(Compute::Destroy, host)
              plan_self(host_id: host.id)
            end
          end

          def finalize
            host = ::Host.find(input[:host_id])
            host.managed_interfaces.each do |nic|
              nic.update_attributes(mac: nil, ip: nil)
            end
          end

        end
      end
    end
  end
end

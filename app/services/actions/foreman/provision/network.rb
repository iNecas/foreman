module Actions
  module Foreman
    module Provision
      module Network
        class Create < ProvisionAction
          def plan(host)
            action_subject(host)
            host.update_attributes!(:build => true)
            sequence do
              compute_create = plan_action(Compute::Create, host)
              host.managed_interfaces.each do |nic|
                plan_action(Dhcp::Create, nic, compute_create.output[:nics][nic.id.to_s])
                plan_action(Tftp::Create, nic)
                plan_action(Tftp::CreateBootFiles, nic)
                plan_action(Dns::CreateARecord, nic)
                plan_action(Dns::CreatePtrRecord, nic)
              end
              plan_action(Compute::PowerUp, host, uuid: compute_create.output[:uuid])
              plan_action(WaitForBuild, host)
              plan_action(Finish, host)
            end
          end

        end

        class Finish < HostAction
          def plan(host)
            sequence do
              super
              host.interfaces.each do |nic|
                plan_action(Tftp::Create, nic) if nic.tftp?
              end
            end
          end

          def run
            host.update_attributes!(:build => false)
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
            host.update_attributes!(:build => false)
            host.managed_interfaces.each do |nic|
              nic.update_attributes!(mac: nil, ip: nil)
            end
          end

        end
      end
    end
  end
end

module Actions
  module Foreman
    module Provision

      class NetworkDown < Actions::EntryAction

        middleware.use Middleware::KeepCurrentUser

        def plan(host)
          # action_subject(host)
          sequence do
            plan_action(Compute::Destroy, host)
            host.managed_interfaces.each do |nic|
              plan_action(SetDhcp, nic)
              plan_action(SetTftp, nic)
              plan_action(SetTftpBootFiles, nic)
              plan_action(SetDnsARecord, nic)
              plan_action(SetDnsPtrRecord, nic)
            end
            plan_action(ComputePowerUp, host)
          end
        end

        def run
          output[:it_works] = true
        end

        def humanized_name
          _("Network provisioning")
        end

        def humanized_input
          input[:host] && input[:host][:name]
        end

      end
    end
  end
end

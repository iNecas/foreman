module Actions
  module Foreman
    module Provision

      class Network < Actions::EntryAction

        middleware.use Middleware::KeepCurrentUser

        def plan(host)
          # action_subject(host)
          host.setBuild
          sequence do
            plan_action(ComputeCreate, host)
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

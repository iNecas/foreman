module Actions
  module Foreman
    module Provision

      class Finish < Actions::EntryAction

        middleware.use Middleware::KeepCurrentUser

        def plan(host)
          host.built(true)
          host.interfaces.each do |nic|
            plan_action(SetTftp, nic) if nic.tftp?
          end
        end

        def humanized_name
          _("Finish network provisioning")
        end

        def humanized_input
          input[:host] && input[:host][:name]
        end

      end
    end
  end
end

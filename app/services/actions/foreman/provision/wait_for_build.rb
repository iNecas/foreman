module Actions
  module Foreman
    module Provision
      class WaitForBuild < HostAction

        include Dynflow::Action::Cancellable

        def run(event = nil)
          case event
          when nil
            suspend do |suspended_action|
              world.clock.ping suspended_action, timeout, :timeout
            end
          when :timeout, :built, Dynflow::Action::Cancellable::Cancel
            output[:event] = event.inspect
          else
            raise "Unexpected event #{event}"
          end
        end

        def timeout
          3000000000
        end

        def self.send_event(host, event)
          if task = ForemanTasks::Task.for_resource(@host).running.first
            wait_for_build_step = task.running_steps.find do |step|
              step.action_class == self
            end
            if wait_for_build_step
              ForemanTasks.dynflow.world.event(wait_for_build_step.execution_plan_id,
                                               wait_for_build_step.id, :built)
            else
              render :text => _("Failed to cancel provisioning: the provision task not running"), :status => :not_found
              return
            end
            render :text => "OK"
            return
          else
            render :text => _("Failed to cancel provisioning: the provision task not running"), :status => :not_found
            return
          end
        end
      end
    end
  end
end

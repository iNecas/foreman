module Foreman

  module Orch

    class << self

      def world
        persistence_adapter = Dynflow::PersistenceAdapters::ActiveRecord.new
        @world ||= Dynflow::SimpleWorld.new(persistence_adapter: persistence_adapter)
      end

      def sync_action(*args)
        _, plan = async_action(*args)
        plan.wait
      end

      def async_action(*args)
        world.trigger(*args)
      end

    end

  end
end

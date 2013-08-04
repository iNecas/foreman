module Foreman

  module Orch

    class << self

      def world
        #persistence_adapter = Dynflow::PersistenceAdapters::ActiveRecord.new
        persistence_adapter = Dynflow::PersistenceAdapters::SimpleFileStorage.new(File.join(Rails.root, 'tmp/dynflow'))
        @world ||= Dynflow::SimpleWorld.new(persistence_adapter: persistence_adapter)
      end

      def sync_action(*args)
        id, plan = async_action(*args)
        plan.wait
        return id, plan
      end

      def async_action(*args)
        world.trigger(*args)
      end

    end

  end
end

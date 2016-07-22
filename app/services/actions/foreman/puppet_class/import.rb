module Actions
  module Foreman
    module PuppetClass
      class Import < Actions::EntryAction
        def resource_locks
          :import_puppetclasses
        end

        def run
          output[:changed] = input[:changed]
          # #obsolete_and_new can return nil if there's no change so we have to be careful with to_sentence
          output[:errors] = ::PuppetClassImporter.new.obsolete_and_new(input[:changed]).try(:to_sentence)
        end

        def rescue_strategy
          ::Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Import Environments and Puppet classes")
        end

        # default value for cleaning up the tasks, it can be overriden by settings
        def self.cleanup_after
          '30d'
        end
      end
    end
  end
end

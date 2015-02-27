module Actions
  module Foreman
    module Provision
      module Tftp
        class Create < NicAction
          def run
            output[:response] = nic.setTFTP.inspect
          end
        end

        class CreateBootFiles < NicAction
          def run
            output[:response] = nic.setTFTPBootFiles.inspect
          end
        end

        class Destroy < NicAction
          def run
            output[:response] = nic.delTFTP.inspect
          end
        end
      end
    end
  end
end

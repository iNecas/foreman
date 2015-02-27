module Actions
  module Foreman
    module Provision
      class SetTftpBootFiles < NicAction
        def run
          output[:response] = nic.setTFTPBootFiles.inspect
        end
      end
    end
  end
end

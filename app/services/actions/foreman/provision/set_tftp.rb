module Actions
  module Foreman
    module Provision
      class SetTftp < NicAction
        def run
          output[:response] = nic.setTFTP.inspect
        end
      end
    end
  end
end

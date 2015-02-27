module Actions
  module Foreman
    module Provision
      class SetDnsPtrRecord < NicAction
        def run
          output[:response] = nic.set_dns_ptr_record.inspect
        end
      end
    end
  end
end

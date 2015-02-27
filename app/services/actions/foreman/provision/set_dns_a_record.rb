module Actions
  module Foreman
    module Provision
      class SetDnsARecord < NicAction
        def run
          output[:response] = nic.set_dns_a_record.inspect
        end
      end
    end
  end
end

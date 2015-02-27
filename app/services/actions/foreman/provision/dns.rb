module Actions
  module Foreman
    module Provision
      module Dns
        class CreateARecord < NicAction
          def run
            output[:response] = nic.set_dns_a_record.inspect
          end
        end

        class CreatePtrRecord < NicAction
          def run
            output[:response] = nic.set_dns_ptr_record.inspect
          end
        end

        class DestroyARecord < NicAction
          def run
            output[:response] = nic.del_dns_a_record.inspect
          end
        end

        class DestroyPtrRecord < NicAction
          def run
            output[:response] = nic.del_dns_ptr_record.inspect
          end
        end
      end
    end
  end
end

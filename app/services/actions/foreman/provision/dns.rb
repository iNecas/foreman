module Actions
  module Foreman
    module Provision
      module Dns
        class Create < NicAction
          def plan(nic, nic_attrs)
            plan_action(ForemanProxy::Dns::ARecord::Create,
                        proxy_url: nic.subnet.dns.url,
                        hostname: nic.hostname,
                        search_domain: nic.domain.name,
                        nameservers: nic.domain.nameservers,
                        nic_attrs: nic_attrs)
            plan_action(ForemanProxy::Dns::PtrRecord::Create,
                        proxy_url: nic.subnet.dns.url,
                        hostname: nic.hostname,
                        nic_attrs: nic_attrs)
          end
        end

        class Destroy < NicAction
          def run
            output[:response] = nic.del_dhcp.inspect
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

module Actions
  module Foreman
    module Provision
      module Dns
        class Create < NicAction
          def plan(nic, nic_attrs)
            plan_dns_proxy_action(ForemanProxy::Dns::ARecord::Create, nic,
                                  search_domain: nic.domain.name,
                                  nameservers: nic.domain.nameservers,
                                  nic_attrs: nic_attrs)
            plan_dns_proxy_action(ForemanProxy::Dns::PtrRecord::Create, nic,
                                  nic_attrs: nic_attrs)
          end
        end

        class Destroy < NicAction
          def plan(nic)
            plan_dns_proxy_action(ForemanProxy::Dns::ARecord::Destroy, nic,
                                  search_domain: nic.domain.name,
                                  nameservers: nic.domain.nameservers)
            plan_dns_proxy_action(ForemanProxy::Dns::PtrRecord::Destroy, nic)
          end
        end
      end
    end
  end
end

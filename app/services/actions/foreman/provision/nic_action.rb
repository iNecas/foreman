module Actions
  module Foreman
    module Provision

      class NicAction < EntryAction

        def plan(nic, args = {})
          plan_self(args.merge(nic_id: nic.id))
        end

        def nic
          @nic ||= ::Nic::Base.find(input[:nic_id])
        end

        def plan_dhcp_proxy_action(klass, nic, attrs = {})
          plan_action(klass,
                      with_nic_attrs(nic, attrs.merge(jumpstart: nic.jumpstart?,
                                                      proxy_url: nic.subnet.dhcp.url,
                                                      attrs: nic.dhcp_attrs.except(:proxy))))
        end

        def plan_tftp_proxy_action(klass, nic, attrs = {})
          plan_action(klass,
                      with_nic_attrs(nic, attrs.merge(variant: nic.host.operatingsystem.pxe_variant,
                                                      proxy_url: nic.subnet.tftp.url)))
        end

        def plan_dns_proxy_action(klass, nic, attrs = {})
          plan_action(klass,
                      with_nic_attrs(nic, attrs.merge(proxy_url: nic.subnet.dns.url,
                                                      hostname: nic.hostname)))
        end

        def with_nic_attrs(nic, attrs)
          { nic_attrs: { ip: nic.ip, mac: nic.mac }}.merge(attrs)
        end

      end
    end
  end
end

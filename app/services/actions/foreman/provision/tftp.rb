module Actions
  module Foreman
    module Provision
      module Tftp
        class SetProvisioning < NicAction
          def plan(nic, nic_attrs)
            plan_tftp_proxy_action(ForemanProxy::Tftp::Create, nic,
                                   nic_attrs: nic_attrs,
                                   pxe_config: nic.generate_pxe_template(true))
            host = nic.host
            host.operatingsystem.pxe_files(host.medium, host.architecture, host).each do |bootfile_info|
              bootfile_info.each do |prefix, path|
                plan_tftp_proxy_action(ForemanProxy::Tftp::FetchBootFile, nic,
                                       nic_attrs: nic_attrs,
                                       prefix: prefix.to_s,
                                       path: path)
              end
            end
          end
        end

        class SetLocalBoot < NicAction
          def plan(nic, nic_attrs)
            plan_tftp_proxy_action(ForemanProxy::Tftp::Create, nic,
                                   nic_attrs: nic_attrs,
                                   pxe_config: nic.generate_pxe_template(false))
          end
        end

        class Destroy < NicAction
          def plan(nic)
            plan_tftp_proxy_action(ForemanProxy::Tftp::Create, nic)
          end
        end
      end
    end
  end
end

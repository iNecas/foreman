module Actions
  module Foreman
    module Provision
      module Tftp
        class SetProvisioning < NicAction
          def plan(nic, nic_attrs)
            proxy_url = nic.subnet.tftp.url
            plan_action(ForemanProxy::Tftp::Create,
                        variant: nic.host.operatingsystem.pxe_variant,
                        proxy_url: proxy_url,
                        pxe_config: nic.generate_pxe_template(true),
                        nic_attrs: nic_attrs)
            host = nic.host
            host.operatingsystem.pxe_files(host.medium, host.architecture, host).each do |bootfile_info|
              bootfile_info.each do |prefix, path|
                plan_action(ForemanProxy::Tftp::FetchBootFile,
                            variant: nic.host.operatingsystem.pxe_variant,
                            proxy_url: proxy_url, prefix: prefix.to_s, path: path)
              end
            end
          end
        end

        class SetLocalBoot < NicAction
          def plan(nic, nic_attrs)
            plan_action(ForemanProxy::Tftp::Create,
                        variant: nic.host.operatingsystem.pxe_variant,
                        proxy_url: nic.subnet.tftp.url,
                        pxe_config: nic.generate_pxe_template(false),
                        nic_attrs: nic_attrs)
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

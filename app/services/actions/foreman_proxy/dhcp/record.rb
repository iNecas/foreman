module Actions
  module ForemanProxy
    module Dhcp
      module Record
        class Create < Base
          input_format do
            param :jumpstart, TrueClass
            param :attrs, Hash
            param :nic_attrs
          end

          output_format do
            param :response
          end

          def proxy
            ProxyAPI::DHCP.new(url: input[:proxy_url])
          end

          def run
            record_class = input[:jumpstart] ? Net::DHCP::SparcRecord : Net::DHCP::Record
            record = record_class.new(dhcp_attributes)
            output[:response] = record.create
          end

          def dhcp_attributes
            ret = input[:attrs].merge(proxy: proxy)
            ret[:mac] = input[:nic_attrs].fetch(:mac, ret[:mac])
            ret[:ip] = input[:nic_attrs].fetch(:ip, ret[:ip])
            ret
          end
        end

        class Destroy < Base
          def run
            output[:response] = nic.del_dhcp.inspect
          end
        end
      end
    end
  end
end

module Actions
  module ForemanProxy
    module Dhcp
      class Base < ForemanProxy::Base
        input_format do
          param :proxy_url, String
          param :jumpstart, TrueClass
          param :attrs, Hash
          param :nic_attrs, Hash
        end

        output_format do
          param :response
        end

        def proxy_class
          ProxyAPI::DHCP
        end

        def record
          record_class = input[:jumpstart] ? Net::DHCP::SparcRecord : Net::DHCP::Record
          record_class.new(dhcp_attributes)
        end

        def dhcp_attributes
          ret = input[:attrs].merge(proxy: proxy)
          ret[:mac] = input[:nic_attrs].fetch(:mac, ret[:mac])
          ret[:ip] = input[:nic_attrs].fetch(:ip, ret[:ip])
          ret
        end
      end

      module Record
        class Create < Dhcp::Base
          def run
            output[:response] = record.create
          end
        end

        class Destroy < Dhcp::Base
          def run
            output[:response] = record.destroy
          end
        end
      end
    end
  end
end

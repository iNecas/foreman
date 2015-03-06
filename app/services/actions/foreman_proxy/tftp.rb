module Actions
  module ForemanProxy
    module Tftp
      class Base < ForemanProxy::Base
        input_format do
          param :variant, String
        end

        def proxy_class
          ProxyAPI::TFTP
        end

        def proxy_attrs
          super.merge(variant: input[:variant])
        end
      end

      class Create < Base
        input_format do
          param :nic_attrs, Hash
          param :pxe_config, String
        end

        def run
          proxy.set(input[:nic_attrs][:mac], pxeconfig: input[:pxe_config])
        end
      end

      class FetchBootFile < Base
        input_format do
          param :proxy_url, String
          param :prefix, String
          param :path, String
        end

        def run
          proxy.fetch_boot_file(prefix: input[:prefix], path: input[:path])
        end
      end

      class Destroy < Base
        input_format do
          param :variant, String
          param :proxy_url, String
          param :mac, String
        end

        def run
          proxy.delete(input[:nic_attrs][:mac])
        end
      end
    end
  end
end

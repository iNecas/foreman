module Actions
  module ForemanProxy
    class Base < Actions::Base
      input_format do
        param :proxy_url, String
      end

      output_format do
        param :response
      end

      def proxy_class
        raise NotImplementedError
      end

      def proxy
        proxy_class.new(proxy_attrs)
      end

      def proxy_attrs
        { url: input[:proxy_url] }
      end
    end
  end
end

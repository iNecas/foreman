module Actions

  module SmartProxy

    class DnsPTRRecordCreate < Dynflow::Action

      def plan(host, ip)
        dns_attrs = host.reverse_dns_record_attrs
        dns_attrs[:proxy_url] = dns_attrs[:proxy].url
        dns_attrs.delete(:proxy)
        dns_attrs[:ip] = ip
        plan_self(dns_attrs)
      end

      input_format do
        param :hostname
        param :ip
        param :proxy_url
      end

      def run
        dns_attrs = input.dup
        proxy = ProxyAPI::DNS.new(url: dns_attrs[:proxy_url].sub('/dns', ''))
        dns_attrs[:proxy] = proxy
        dns_record = Net::DNS::PTRRecord.new(dns_attrs)
        dns_record.create
        output[:ip] = dns_attrs[:ip]
      end

    end
  end
end

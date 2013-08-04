module Actions

  module SmartProxy

    class DnsARecordCreate < Dynflow::Action

      def plan(host, ip)
        dns_attrs = host.dns_record_attrs
        dns_attrs[:proxy_url] = dns_attrs[:proxy].url
        dns_attrs.delete(:proxy)
        dns_attrs[:ip] = ip
        dns_attrs[:resolver] = { search: host.domain.name,
                                 nameserver: host.domain.nameservers,
                                 ndots: 1 }
        plan_self(dns_attrs)
      end

      input_format do
        param :hostname
        param :ip
        param :proxy_url
        param :resolver, Hash do
          param :search
          param :nameserver
          param :ndots
        end
      end


      def run
        resolv_params = input[:resolver][:nameserver].empty? ? nil : input[:resolver]
        resolver =  Resolv::DNS.new(resolv_params)

        dns_attrs = input.dup
        proxy = ProxyAPI::DNS.new(url: dns_attrs[:proxy_url].sub('/dns', ''))
        dns_attrs[:proxy] = proxy
        dns_attrs[:resolver] = resolver
        dns_record = Net::DNS::ARecord.new(dns_attrs)
        dns_record.create
        output[:ip] = dns_attrs[:ip]
      end

    end
  end
end

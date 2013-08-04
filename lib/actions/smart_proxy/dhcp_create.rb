module Actions

  module SmartProxy

    class DhcpCreate < Dynflow::Action

      def plan(host)
        dhcp_attrs = host.dhcp_attrs
        dhcp_attrs[:proxy_url] = dhcp_attrs[:proxy].url
        dhcp_attrs.delete(:proxy)
        dhcp_attrs[:subnet_id] = host.subnet.id
        plan_self(dhcp_attrs)
      end

      input_format do
        param :name
        param :filename
        param :subnet_id
        param :ip
        param :mac
        param :hostname
        param :proxy_url
        param :network
        param :nextServer
      end

      output_format do
        param :ip
      end

      def run
        dhcp_attrs = input.dup
        proxy = ProxyAPI::DHCP.new(url: dhcp_attrs[:proxy_url].sub('/dhcp', ''))
        dhcp_attrs[:proxy] = proxy
        if dhcp_attrs[:ip].blank?
          subnet = Subnet.find(input[:subnet_id])
          dhcp_attrs[:ip] = subnet.unused_ip
        end
        dhcp_record = Net::DHCP::Record.new(dhcp_attrs)
        dhcp_record.create
        output[:ip] = dhcp_attrs[:ip]
      end

    end
  end
end

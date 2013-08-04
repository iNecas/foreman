module Actions

  class HostCreate < Dynflow::Action

    def plan(host)
      host.save!

      dhcp = plan_action(SmartProxy::DhcpCreate, host)
      plan_action(SmartProxy::DnsCreate, host, dhcp.output[:ip])
      plan_self(id: host.id, ip: dhcp.output[:ip], user_id: User.current.id)
    end

    input_format do
      params :id
      params :ip
      params :user_id
    end

    def finalize
      User.current = User.find(input[:user_id])
      host = Host.find(input[:id])
      host.update_attributes!(ip: input[:ip])
    ensure
      User.current = nil
    end

  end
end

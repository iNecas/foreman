module Actions
  module SmartProxy
    class DnsCreate < Dynflow::Action

      def plan(host, ip)
        plan_action(DnsARecordCreate, host, ip)
        plan_action(DnsPTRRecordCreate, host, ip)
      end

    end
  end
end

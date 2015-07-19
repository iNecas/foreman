module Actions
  module ForemanProxy
    module Dns
      class Base < ForemanProxy::Base
        def proxy_class
          ProxyAPI::DNS
        end
      end

      module ARecord
        class Base < Dns::Base
          input_format do
            param :proxy_url, String
            param :hostname, String
            param :search_domain, String
            param :nameservers, Array
            param :nic_attrs, Hash
          end

          output_format do
            param :response
          end

          def dns_a_record
            Net::DNS::ARecord.new(hostname: input[:hostname],
                                  ip:       input[:nic_attrs][:ip],
                                  resolver: resolver,
                                  proxy:    proxy)
          end

          def resolver
            dns_attrs = unless input[:nameservers].empty?
                          { search:     input[:search_domain],
                            nameserver: input[:nameservers],
                            ndots:      1 }
                        end
            Resolv::DNS.new dns_attrs
          end
        end

        class Create < Base
          def run
            output[:response] = dns_a_record.create
          end
        end

        class Destroy < Base
          def run
            output[:response] = dns_a_record.destroy
          end
        end
      end

      module PtrRecord
        class Base < Dns::Base
          input_format do
            param :proxy_url, String
            param :hostname, String
            param :nic_attrs, Hash
          end

          output_format do
            param :response
          end

          def dns_ptr_record
            Net::DNS::PTRRecord.new(hostname: input[:hostname],
                                    ip:       input[:nic_attrs][:ip],
                                    proxy:    proxy)
          end
        end

        class Create < Base
          def run
            output[:response] = dns_ptr_record.create
          end
        end

        class Destroy < Base
          def run
            output[:response] = dns_ptr_record.destroy
          end
        end
      end
    end
  end
end

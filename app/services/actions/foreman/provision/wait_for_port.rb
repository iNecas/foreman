require 'socket'

module Actions
  module Foreman
    module Provision
      class WaitForPort < Base

        include Dynflow::Action::Polling
        include Dynflow::Action::Cancellable

        input_format do
          param :nic_attrs
          param :port
        end

        def external_task
          output[:status]
        end

        def done?
          output[:port_open_at]
        end

        def cancel!
          # just do nothing
        end

        private

        def invoke_external_task
          nil
        end

        def external_task=(external_task_data)
          output[:status] = external_task_data
        end

        def poll_external_task
          if check_port_open
            output[:port_open_at] = Time.now.to_i
          end
        end

        def poll_interval
          3
        end

        def ip
          input[:nic_attrs][:ip]
        end

        def port
          input[:port]
        end

        def check_port_open
          try_connection(ip, port, 1)
        end

        # inspired by http://spin.atomicobject.com/2013/09/30/socket-connection-timeout-ruby/
        # to awoid Timeout class, as it's not platform independent and
        # uses extra thread for doing so.
        def try_connection(host, port, timeout)
          # Convert the passed host into structures the non-blocking calls
          # can deal with
          addr = Socket.getaddrinfo(host, nil)
          sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])
          Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0).tap do |socket|
            socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
            begin
              socket.connect_nonblock(sockaddr)
            rescue IO::WaitWritable
              if IO.select(nil, [socket], nil, timeout)
                begin
                  # Verify there is now a good connection
                  socket.connect_nonblock(sockaddr)
                  return true
                rescue Errno::EISCONN
                  # already connected
                  return true
                rescue
                  return false
                ensure
                  socket.close
                end
              else
                # timeout passed
                socket.close
                return false
              end
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
              return false
            end
          end
        end
      end
    end
  end
end

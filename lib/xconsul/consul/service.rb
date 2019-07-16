# consul service 调用封装
module Xconsul
  module Consul
    class Service
      # 返回示例: ['10.10.142.233:8890', '192.168.0.2:8901']
      def self.hosts_with_port(service_name)
        services = Diplomat::Service.get(service_name, :all)
        services.map { |service| "#{service.Address}:#{service.ServicePort}" }
      end
    end
  end
end

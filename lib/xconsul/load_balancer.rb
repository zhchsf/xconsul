# 负责load balance算法调用封装
require_relative 'load_balance/base'
require_relative 'consul/service'

module Xconsul
  # balancer = Xconsul::LoadBalancer.new({}); balancer.host
  class LoadBalancer
    DEFAULT_CACHE_EXPIRED_SECONDS = 30

    attr_accessor :consul_service_name # consul service 名称
    attr_accessor :latest_hosts # 最近一次获取的hosts
    attr_accessor :last_timestamp # 上次获取hosts的时间戳
    attr_accessor :cache_expired_seconds # hosts缓存有效期，每隔一定时间从consul获取最新list，不传使用默认值
    attr_accessor :load_balance_processor # load balancer

    # consul_options
    #   service_name（必填）: consul服务的名称
    #   cache_expired_seconds（可选）：hosts缓存有效期，每隔一定时间从consul获取最新list，不传使用默认值
    #   use_fixed_hosts（可选，默认false）: 为true使用固定hosts，主要用于dev环境，或者暂时不使用consul
    #   fixed_hosts（可选）: 手工配置的hosts列表，当use_fixed_hosts 为true时必须传入，格式为['10.10.142.233:8890', 'xxx']
    # balance_options [Hash]:
    #   balance_algorithm 负载均衡算法，暂时无用，只有一种算法，自动使用
    def initialize(consul_options, balance_options = {})
      @consul_service_name = consul_options[:service_name]
      @cache_expired_seconds = consul_options[:cache_expired_seconds].to_i
      @cache_expired_seconds = DEFAULT_CACHE_EXPIRED_SECONDS if @cache_expired_seconds <= 5

      balance_algorithm = :round_robin
      @load_balance_processor = generate_load_balance_processor(balance_algorithm)

      if consul_options[:use_fixed_hosts] == true
        @latest_hosts = consul_options[:fixed_hosts]
        @last_timestamp = Time.now.to_i + 315360000 # 设置一个未来10年的时间戳，cache不过期
      else
        @latest_hosts = []
      end
    end

    # 获取一个host with port，示例：'10.10.142.233:8890'
    def host
      hosts = hosts_with_cache
      raise "consul_service:#{consul_service_name} 无可用hosts" if hosts.length.zero?
      @load_balance_processor.select(hosts)
    end

    private

      def generate_load_balance_processor(balance_algorithm)
        ::Xconsul::LoadBalance::Base.generate(balance_algorithm)
      end

      # 带cache的hosts
      # 如果没有过期，并且hosts不为空，则返回上次结果，否则重新查consul
      def hosts_with_cache
        if not_expired?
          return latest_hosts unless latest_hosts.length.zero?
        end
        @latest_hosts = Xconsul::Consul::Service.hosts_with_port(consul_service_name)
        @last_timestamp = Time.now.to_i
        @latest_hosts
      end

      # 判断是否在有效期内
      def not_expired?
        return false unless last_timestamp
        (last_timestamp + cache_expired_seconds) >= Time.now.to_i
      end
  end
end

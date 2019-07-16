require 'diplomat'
require "xconsul/version"
require "xconsul/load_balancer"

module Xconsul

  # 通过此方法生成一个balancer，后面获取host时调用 balancer.host（'10.10.142.233:8890'）
  # 所有Hash key请传入symbol格式
  # consul_options [Hash]: 详细见::Xconsul::LoadBalancer内注释
  # balance_options [Hash]: 暂时不需要传
  #   balance_algorithm 负载均衡算法，暂时无用，只有一种算法，自动使用
  def self.gen_balancer(consul_options, balance_options = {})
    ::Xconsul::LoadBalancer.new(consul_options, balance_options)
  end

  # 注意：这个配置是全局行的，配置后其他gem调用consul也会生效，所以要求所有的必须使用同一个consul服务
  # consul_options [Hash]: 示例
  # {
  #    url: 'consul 地址，不传Diplomat会使用默认localhost地址',
  #    config_options: {ssl: {version: :TLSv1_2}, headers: {"X-Consul-Token" => "xxxx"}
  # }
  # 其他参数有需要时再加
  def self.configure_consul_connection(consul_options)
    return if consul_options.length.zero?
    url = consul_options[:url]
    config_options = consul_options[:config_options] || {}

    Diplomat.configure do |config|
      config.url = url if url
      config.options = config_options
    end
  end
end

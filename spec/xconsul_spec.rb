require 'spec_helper'

RSpec.describe Xconsul do
  it "has a version number" do
    expect(Xconsul::VERSION).not_to be nil
  end

  describe '#gen_balancer' do
    context '全量配置 负载均衡算法非内部指定' do
      before do
        @consul_options = {
          service_name: 'service_name',
          cache_expired_seconds: 60
        }
      end

      it '配置正确' do
        balancer = Xconsul.gen_balancer(@consul_options, {balance_algorithm: :xxx})
        expect(balancer.consul_service_name).to eq 'service_name'
        expect(balancer.cache_expired_seconds).to eq 60
        expect(balancer.load_balance_processor.class).to eq Xconsul::LoadBalance::RoundRobin
      end
    end
  end

  describe '#configure_consul_connection' do
    subject { Xconsul.configure_consul_connection(@consul_options) }

    context '没有配置信息' do
      before do
        @consul_options = {}
      end

      it 'configuration is default' do
        subject
        expect(Diplomat.configuration.url).to eq 'http://localhost:8500'
        expect(Diplomat.configuration.options).to eq({})
      end
    end

    context '没有url' do
      before do
        @config_options = { headers: { "X-Consul-Token" => "xxxx" } }
        @consul_options = {
          config_options: @config_options
        }
      end

      it 'configuration is right' do
        subject
        expect(Diplomat.configuration.url).to eq 'http://localhost:8500'
        expect(Diplomat.configuration.options).to eq @config_options
      end
    end

    context '没有config_options' do
      before do
        @consul_options = { url: 'http://localhost:8888' }
      end

      it 'configuration is right' do
        subject
        expect(Diplomat.configuration.url).to eq 'http://localhost:8888'
        expect(Diplomat.configuration.options).to eq({})
      end
    end

    context '传了url & config_options' do
      before do
        @config_options = { headers: { "X-Consul-Token" => "xxxx" } }
        @consul_options = {
          url: 'http://localhost:8888',
          config_options: @config_options
        }
      end

      it 'configuration is right' do
        subject
        expect(Diplomat.configuration.url).to eq 'http://localhost:8888'
        expect(Diplomat.configuration.options).to eq(@config_options)
      end
    end
  end
end

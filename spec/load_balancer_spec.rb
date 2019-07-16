require 'spec_helper'

RSpec.describe Xconsul::LoadBalancer do
  describe '测试配置' do
    context 'cache_expired_seconds 传0' do
      it '实际设置为默认值' do
        balancer = Xconsul.gen_balancer({ service_name: 'service_name' })
        expect(balancer.cache_expired_seconds).to eq 30
        expect(balancer.load_balance_processor.class).to eq Xconsul::LoadBalance::RoundRobin
        expect(balancer.latest_hosts).to eq []
      end
    end

    context 'use_fixed_hosts = true, set fixed_hosts' do
      before do
        @options = {
          service_name: 'service_name',
          use_fixed_hosts: true,
          fixed_hosts: ['10.9.60.73:8890']
        }
      end

      it do
        balancer = Xconsul.gen_balancer(@options)
        expect(balancer.cache_expired_seconds).to eq 30
        expect(balancer.latest_hosts).to eq @options[:fixed_hosts]
        expect(balancer.last_timestamp > Time.now.to_i + 30000000).to eq true
      end
    end
  end

  describe '#host; round robin负载; 使用consul动态获取hosts' do
    before do
      @consul_options = {
        service_name: 'service_name',
        cache_expired_seconds: 60
      }
      @balancer = Xconsul.gen_balancer(@consul_options)
    end

    context '没有请求过consul hosts，连续请求2次' do
      before do
        consul_response = [{"ID":"71fe5821-9d58-5670-b7de-f7987d633905","Node":"node_2","Address":"10.9.60.73","Datacenter":"global","TaggedAddresses":{"lan":"10.9.60.73","wan":"10.9.60.73"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"web","ServiceName":"web","ServiceTags":["rails"],"ServiceAddress":"","ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{},"ServicePort":8890,"ServiceEnableTagOverride":false,"ServiceProxyDestination":"","ServiceProxy":{},"ServiceConnect":{},"CreateIndex":662308,"ModifyIndex":662308},{"ID":"5eca8da6-c1f1-ea5c-c9f0-0ed6ed63d038","Node":"node_client_116_249","Address":"10.10.116.249","Datacenter":"global","TaggedAddresses":{"lan":"10.10.116.249","wan":"10.10.116.249"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"web","ServiceName":"web","ServiceTags":["rails"],"ServiceAddress":"","ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{},"ServicePort":8882,"ServiceEnableTagOverride":false,"ServiceProxyDestination":"","ServiceProxy":{},"ServiceConnect":{},"CreateIndex":655489,"ModifyIndex":659450}]
        stub_consul_service_query(consul_response)
      end

      it '第一次请求consul 并返回第一个host；第二次请求返回第二个...' do
        expect(@balancer.send(:not_expired?)).to eq false
        expect(@balancer.load_balance_processor.counter).to eq 0
        expect(@balancer.host).to eq '10.9.60.73:8890'
        expect(@balancer.send(:not_expired?)).to eq true
        expect(@balancer.load_balance_processor.counter).to eq 1
        expect(@balancer.host).to eq '10.10.116.249:8882'
        expect(@balancer.send(:not_expired?)).to eq true
        expect(@balancer.load_balance_processor.counter).to eq 2
        expect(@balancer.host).to eq '10.9.60.73:8890'
      end
    end

    context 'consul返回hosts为空' do
      before do
        consul_response = []
        stub_consul_service_query(consul_response)
      end

      it '报错无可用host' do
        expect { @balancer.host }.to raise_error "consul_service:service_name 无可用hosts"
      end
    end

    context '调用host后，再过10分钟后再调用' do
      before do
        consul_response = [{"ID":"71fe5821-9d58-5670-b7de-f7987d633905","Node":"node_2","Address":"10.9.60.73","Datacenter":"global","TaggedAddresses":{"lan":"10.9.60.73","wan":"10.9.60.73"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"web","ServiceName":"web","ServiceTags":["rails"],"ServiceAddress":"","ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{},"ServicePort":8890,"ServiceEnableTagOverride":false,"ServiceProxyDestination":"","ServiceProxy":{},"ServiceConnect":{},"CreateIndex":662308,"ModifyIndex":662308},{"ID":"5eca8da6-c1f1-ea5c-c9f0-0ed6ed63d038","Node":"node_client_116_249","Address":"10.10.116.249","Datacenter":"global","TaggedAddresses":{"lan":"10.10.116.249","wan":"10.10.116.249"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"web","ServiceName":"web","ServiceTags":["rails"],"ServiceAddress":"","ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{},"ServicePort":8882,"ServiceEnableTagOverride":false,"ServiceProxyDestination":"","ServiceProxy":{},"ServiceConnect":{},"CreateIndex":655489,"ModifyIndex":659450}]
        stub_consul_service_query(consul_response)
      end

      it '第二次调用timestamp过期，会重新获取' do
        expect(@balancer.send(:not_expired?)).to eq false
        expect(@balancer.load_balance_processor.counter).to eq 0
        expect(@balancer.host).to eq '10.9.60.73:8890'
        expect(@balancer.send(:not_expired?)).to eq true
        Timecop.freeze(Time.now + 600)
        expect(@balancer.send(:not_expired?)).to eq false
      end
    end
  end

  describe '#host; use_fixed_hosts true; round robin负载; ' do
    before do
      @consul_options = {
        service_name: 'service_name',
        use_fixed_hosts: true,
        fixed_hosts: ['10.10.116.249:8881', '10.10.116.249:8882']
      }
      @balancer = Xconsul.gen_balancer(@consul_options)
    end

    it '第一次请求consul 并返回第一个host；第二次请求返回第二个...' do
      expect(@balancer.send(:not_expired?)).to eq true
      expect(@balancer.load_balance_processor.counter).to eq 0
      expect(@balancer.host).to eq '10.10.116.249:8881'
      expect(@balancer.send(:not_expired?)).to eq true
      expect(@balancer.load_balance_processor.counter).to eq 1
      expect(@balancer.host).to eq '10.10.116.249:8882'
      expect(@balancer.send(:not_expired?)).to eq true
      expect(@balancer.load_balance_processor.counter).to eq 2
      expect(@balancer.host).to eq '10.10.116.249:8881'
    end
  end
end

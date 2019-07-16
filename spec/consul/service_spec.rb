require 'spec_helper'

RSpec.describe Xconsul::Consul::Service do
  describe '#hosts_with_port' do
    context 'consul返回空hosts' do
      before do
        consul_response = []
        stub_consul_service_query(consul_response)
      end

      it '返回空数组' do
        hosts = Xconsul::Consul::Service.hosts_with_port('service_name')
        expect(hosts).to eq []
      end
    end

    context 'consul返回有值' do
      before do
        consul_response = [{"ID":"71fe5821-9d58-5670-b7de-f7987d633905","Node":"node_2","Address":"10.9.60.73","Datacenter":"global","TaggedAddresses":{"lan":"10.9.60.73","wan":"10.9.60.73"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"web","ServiceName":"web","ServiceTags":["rails"],"ServiceAddress":"","ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{},"ServicePort":8890,"ServiceEnableTagOverride":false,"ServiceProxyDestination":"","ServiceProxy":{},"ServiceConnect":{},"CreateIndex":662308,"ModifyIndex":662308},{"ID":"5eca8da6-c1f1-ea5c-c9f0-0ed6ed63d038","Node":"node_client_116_249","Address":"10.10.116.249","Datacenter":"global","TaggedAddresses":{"lan":"10.10.116.249","wan":"10.10.116.249"},"NodeMeta":{"consul-network-segment":""},"ServiceKind":"","ServiceID":"web","ServiceName":"web","ServiceTags":["rails"],"ServiceAddress":"","ServiceWeights":{"Passing":1,"Warning":1},"ServiceMeta":{},"ServicePort":8882,"ServiceEnableTagOverride":false,"ServiceProxyDestination":"","ServiceProxy":{},"ServiceConnect":{},"CreateIndex":655489,"ModifyIndex":659450}]
        stub_consul_service_query(consul_response)
      end

      it 'hosts正确' do
        hosts = Xconsul::Consul::Service.hosts_with_port('service_name')
        expect(hosts).to eq ['10.9.60.73:8890', '10.10.116.249:8882']
      end
    end
  end
end

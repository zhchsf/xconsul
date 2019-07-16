require 'spec_helper'

RSpec.describe Xconsul::LoadBalance::RoundRobin do
  before do
    @round_robin = Xconsul::LoadBalance::RoundRobin.new
  end

  context '没有做任何调用时' do
    it 'counter = 0' do
      expect(@round_robin.counter).to eq 0
    end
  end

  describe '#select' do
    before do
      @hosts = ['192.168.0.1:8909', '192.168.0.2:8901', '192.168.0.3:8903']
    end

    context '多次调用' do
      it '轮询调度' do
        expect(@round_robin.select(@hosts)).to eq @hosts[0]
        expect(@round_robin.select(@hosts)).to eq @hosts[1]
        expect(@round_robin.select(@hosts)).to eq @hosts[2]
        expect(@round_robin.select(@hosts)).to eq @hosts[0]
        expect(@round_robin.select(@hosts)).to eq @hosts[1]
        expect(@round_robin.select(@hosts)).to eq @hosts[2]
        expect(@round_robin.select(@hosts)).to eq @hosts[0]
      end
    end
  end
end

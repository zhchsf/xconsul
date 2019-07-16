# 轮训调度算法
# 最简单策略，调用计数器每调用一次+1，调用数 % hosts数，根据mod值取host
# 计算器暂时不做线程安全处理，1 不需要完全这么精确，并发发同一host多个也无所谓，2 减少代码锁
module Xconsul
  module LoadBalance
    class RoundRobin
      # attr_accessor :hosts # ['192.168.0.1:8909']
      attr_accessor :counter # Integer

      def initialize
        @counter = 0
      end

      # hosts ['192.168.0.1:8909', '192.168.0.2:8901']
      def select(hosts)
        idx = @counter % hosts.size
        @counter += 1
        hosts[idx]
      end
    end
  end
end

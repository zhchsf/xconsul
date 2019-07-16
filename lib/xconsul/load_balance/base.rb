require_relative 'round_robin'
module Xconsul
  module LoadBalance
    class Base
      # balance_algorithm 请传sym格式
      def self.generate(balance_algorithm)
        case balance_algorithm
        when :round_robin
          return RoundRobin.new
        else
          raise '未支持的load balance算法'
        end
      end
    end
  end
end

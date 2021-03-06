require "logger"

module RSpec
  module Parallel
    # Stores runtime configuration information.
    #
    # @!attribute concurrency
    #   @return [Integer]
    class Configuration
      DEFULT_AFTER_FORK = ->(_worker) {}

      def after_fork(&block)
        @after_fork_block = block_given? ? block : DEFULT_AFTER_FORK
      end

      def after_fork_block
        @after_fork_block ||= DEFULT_AFTER_FORK
      end

      # @return [Integer]
      def concurrency
        @concurrency ||=
          if File.exist?("/proc/cpuinfo")
            File.read("/proc/cpuinfo").split("\n").grep(/processor/).size
          elsif RUBY_PLATFORM =~ /darwin/
            `/usr/sbin/sysctl -n hw.activecpu`.to_i
          else
            2
          end
      end

      # @return [Logger]
      def logger
        @logger ||= Logger.new(STDERR).tap do |logger|
          logger.level = log_level
        end
      end

      # @return [Integer]
      def log_level
        @log_level ||= Logger::INFO
      end

      attr_writer :concurrency, :logger, :log_level
    end
  end
end

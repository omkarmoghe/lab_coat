# frozen_string_literal: true

module LabCoat
  class Observation
    attr_reader :name, :experiment, :duration_seconds, :value, :error, :publishable_value

    def initialize(name, experiment, &block)
      @name = name
      @experiment = experiment

      start_at = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
      begin
        @value = block.call
      rescue StandardError => e
        @error = e
      ensure
        @duration_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second) - start_at
      end
    end

    # @return [Object] A publishable representation of this observation's `value`. Typically something that is
    # serializable
    def publishable_value
      @publishable_value ||= experiment.publishable_value(value)
    end

    # @return [TrueClass, FalseClass]
    def raised?
      !error.nil?
    end

    # @return [TrueClass, FalseClass]
    def control?
      name == "control"
    end

    # @return [TrueClass, FalseClass]
    def candidate?
      !control?
    end
  end
end

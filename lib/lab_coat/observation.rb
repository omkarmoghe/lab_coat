# frozen_string_literal: true

module LabCoat
  # A wrapper around some behavior that captures the resulting `value` and any exceptions thrown.
  class Observation
    attr_reader :name, :experiment, :duration, :value, :error, :publishable_value

    def initialize(name, experiment, &block) # rubocop:disable Metrics/MethodLength
      @name = name
      @experiment = experiment

      start_at = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
      begin
        @value = block.call
        @publishable_value = experiment.publishable_value(self)
      rescue StandardError => e
        @error = e
      ensure
        @duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second) - start_at
      end

      freeze
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

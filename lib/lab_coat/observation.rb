# frozen_string_literal: true

module LabCoat
  # A wrapper around some behavior that captures the resulting `value` and any exceptions thrown.
  class Observation
    attr_reader :name, :experiment, :duration, :value, :error

    def initialize(name, experiment, &block)
      @name = name
      @experiment = experiment

      start_at = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
      begin
        @value = block.call
      rescue StandardError => e
        @error = e
      ensure
        @duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second) - start_at
      end
    end

    def publishable_value
      @publishable_value ||= experiment.publishable_value(self)
    end

    # @return [TrueClass, FalseClass]
    def raised?
      !error.nil?
    end
  end
end

# frozen_string_literal: true

module LabCoat
  # A wrapper around some behavior that captures the resulting `value` and any exceptions thrown.
  class Observation
    attr_reader :name, :experiment, :duration, :value, :error

    def initialize(name, experiment, &block)
      @name = name
      @experiment = experiment

      @duration = Benchmark.measure(name) do
        @value = block.call
      rescue StandardError => e
        @error = e
      end
    end

    def publishable_value
      @publishable_value ||= experiment.publishable_value(self)
    end

    # @return [TrueClass, FalseClass]
    def raised?
      !error.nil?
    end

    # @return [String] String representing this `Observation`.
    def slug
      "#{experiment.name}.#{name}"
    end

    # @return [Hash] A hash representation of this `Observation`. Useful when publishing `Results`.
    def to_h
      {
        name: name,
        experiment: experiment.name,
        slug: slug,
        value: publishable_value,
        duration: duration.to_h,
        error_class: error&.class&.name,
        error_message: error&.message
      }.compact
    end
  end
end

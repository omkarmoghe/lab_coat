# frozen_string_literal: true

module LabCoat
  class Experiment
    attr_reader :name

    def initialize(name)
      @name = name
    end

    # Override this method to control whether or not the experiment runs.
    # @return [TrueClass, FalseClass]
    def enabled?(...)
      raise MustOverrideError, "`#enabled?` must be implemented in your Experiment class."
    end

    # Override this method to define the existing aka "control" behavior.
    def control(...)
      raise MustOverrideError, "`#control` must be implemented in your Experiment class."
    end

    # Override this method to define the new aka "candidate" behavior.
    # @param context [Hash] Any data needed for the candidate to run that has to be passed into `#run`.
    def candidate(...)
      raise MustOverrideError, "`#candidate` must be implemented in your Experiment class."
    end

    # Override this method to define what is considered a match or mismatch. Must return a boolean.
    # @param control_value [Object] The return value of the `control` method.
    # @param candidate_value [Object] The return value of the `candidate` method.
    # @return [TrueClass, FalseClass]
    def compare(control_value, candidate_value)
      control_value == candidate_value
    end

    # Called when the control and/or candidate observations raise an error.
    # @param observation [LabCoat::Observation]
    def raised(observation); end

    # Override this method to transform the value for publishing. This could mean turning the value into something
    # serializable (e.g. JSON).
    def publishable_value(value)
      value
    end

    # Override this method to publish the `Result`. It's recommended to override this once in an application wide base
    # class.
    # @param result [LabCoat::Result] The result of this experiment.
    def publish!(result); end

    # Runs the control and candidate and publishes the result. Always returns the result of `control`.
    # @param context [Hash] Any data needed at runtime.
    def run!(...)
      # Run the control and exit early if the experiment is not enabled.
      control = Observation.new("control", self) do
        control(...)
      end
      raised(control) if control.raised?
      return control.value unless enabled?(...)

      candidate = Observation.new("candidate", self) do
        candidate(...)
      end
      raised(candidate) if candidate.raised?

      # Compare and publish the results.
      matched = compare(control.value, candidate.value)
      result = Result.new(self, control, candidate, matched)
      publish!(result)

      # Always return the control.
      control.value
    end
  end
end

# frozen_string_literal: true

module LabCoat
  # A base experiment class meant to be subclassed to define various experiments.
  class Experiment
    attr_reader :name, :context

    def initialize(name)
      @name = name
      @context = {}
    end

    # Override this method to control whether or not the experiment runs.
    # @return [TrueClass, FalseClass]
    def enabled?
      raise InvalidExperimentError, "`#enabled?` must be implemented in your Experiment class."
    end

    # Override this method to define the existing aka "control" behavior. This method is always run, even when
    # `enabled?` is false.
    # @return [Object] Anything.
    def control
      raise InvalidExperimentError, "`#control` must be implemented in your Experiment class."
    end

    # Override this method to define the new aka "candidate" behavior. Only run if the experiment is enabled.
    # @return [Object] Anything.
    def candidate
      raise InvalidExperimentError, "`#candidate` must be implemented in your Experiment class."
    end

    # Override this method to define what is considered a match or mismatch. Must return a boolean.
    # @param control [LabCoat::Observation] The control `Observation`.
    # @param candidate [LabCoat::Observation] The candidate `Observation`.
    # @return [TrueClass, FalseClass]
    def compare(control, candidate)
      control.value == candidate.value
    end

    # Override this method to define which results are ignored. Must return a boolean.
    def ignore?(_control, _candidate)
      false
    end

    # Called when the control and/or candidate observations raise an error.
    # @param observation [LabCoat::Observation]
    def raised(observation); end

    # Override this method to transform the value for publishing. This could mean turning the value into something
    # serializable (e.g. JSON).
    # @param observation [LabCoat::Observation]
    def publishable_value(observation)
      observation.value
    end

    # Override this method to publish the `Result`. It's recommended to override this once in an application wide base
    # class.
    # @param result [LabCoat::Result] The result of this experiment.
    def publish!(result); end

    # Runs the control and candidate and publishes the result. Always returns the result of `control`.
    # @param context [Hash] Any data needed at runtime.
    def run!(**context)
      # Set the context for this run.
      @context = context

      # Run the control and exit early if the experiment is not enabled.
      control_obs = Observation.new("control", self) { control }
      raised(control_obs) if control_obs.raised?
      return control_obs.value unless enabled?

      # Run the candidate.
      candidate_obs = Observation.new("candidate", self) { candidate }
      raised(candidate_obs) if candidate_obs.raised?

      # Compare and publish the results.
      result = Result.new(self, control_obs, candidate_obs)
      publish!(result)

      # Reset the context for this run.
      @context = {}

      # Always return the control.
      control_obs.value
    end
  end
end

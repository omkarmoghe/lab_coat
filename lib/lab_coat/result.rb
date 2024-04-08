# frozen_string_literal: true

module LabCoat
  # The result of a single `Experiment` run, that is published by the `Experiment`.
  class Result
    attr_reader :experiment, :control, :candidate

    def initialize(experiment, control, candidate)
      @experiment = experiment
      @control = control
      @candidate = candidate
      @matched = experiment.compare(control, candidate)
      @ignored = experiment.ignore?(control, candidate)

      freeze
    end

    # Whether or not the control and candidate match, as defined by `Experiment#compare`.
    # @return [TrueClass, FalseClass]
    def matched?
      @matched
    end

    # Whether or not the result should be ignored, as defined by `#Experiment#ignore?`.
    # @return [TrueClass, FalseClass]
    def ignored?
      @ignored
    end
  end
end

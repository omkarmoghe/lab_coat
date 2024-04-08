# frozen_string_literal: true

module LabCoat
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

    def matched?
      @matched
    end

    def ignored?
      @ignored
    end
  end
end

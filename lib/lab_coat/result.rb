# frozen_string_literal: true

module LabCoat
  class Result
    attr_reader :experiment, :control, :candidate, :matched

    def initialize(experiment, control, candidate, matched)
      @experiment = experiment
      @control = control
      @candidate = candidate
      @matched = matched

      freeze
    end

    def matched?
      @matched
    end
  end
end

# frozen_string_literal: true

require "test_helper"

class TestResult < Minitest::Test
  TestResultExperiment = Class.new(LabCoat::Experiment) do
    def ignore?(control, candidate)
      control.value == "success" && candidate.value == "success"
    end
  end

  def setup
    experiment = TestResultExperiment.new("test_experiment")
    control = LabCoat::Observation.new("control", experiment) { "success" }
    candidate = LabCoat::Observation.new("candidate", experiment) { "success" }
    @result = LabCoat::Result.new(experiment, control, candidate)
  end

  def test_matched?
    assert(@result.matched?)
  end

  def test_ignored?
    assert(@result.ignored?)
  end
end

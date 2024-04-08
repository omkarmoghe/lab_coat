# frozen_string_literal: true

require "test_helper"

class TestObservation < Minitest::Test
  TestObservationExperiment = Class.new(LabCoat::Experiment) do
    def publishable_value(observation)
      "publishable #{observation.value}"
    end
  end

  def setup
    @experiment = TestObservationExperiment.new("test_experiment")
    @observation = LabCoat::Observation.new("control", @experiment) { "success" }
  end

  def test_duration
    assert_operator(@observation.duration, :>=, 0)
  end

  def test_value
    assert_equal("success", @observation.value)
  end

  def test_publishable_value
    assert_equal("publishable success", @observation.publishable_value)
  end

  def test_error
    observation = LabCoat::Observation.new("control", @experiment) do
      raise StandardError, "boom!"
    end

    refute_nil(observation.error)
    assert(observation.raised?)
    assert_kind_of(StandardError, observation.error)
  end

  def test_slug
    assert_equal("test_experiment.control", @observation.slug)
  end
end

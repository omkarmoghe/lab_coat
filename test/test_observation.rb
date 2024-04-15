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
    assert_kind_of(Benchmark::Tms, @observation.duration)
    assert_operator(@observation.duration.real, :>=, 0)
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

  def test_to_h
    hash = @observation.to_h
    assert_includes(hash, :name)
    assert_includes(hash, :experiment)
    assert_includes(hash, :slug)
    assert_includes(hash, :value)
    assert_includes(hash, :duration)
    refute_includes(hash, :error_class)
    refute_includes(hash, :error_message)
  end
end

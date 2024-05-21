# frozen_string_literal: true

require "test_helper"
require "json"

class TestExperiment < Minitest::Test
  TestExperiment = Class.new(LabCoat::Experiment) do
    attr_reader :raised_observations, :publish_io

    def enabled?
      context[:num]&.even?
    end

    def control
      { result: "abc", status: :ok }
    end

    def candidate
      raise StandardError, "boom!"
    end

    def compare(control, candidate)
      return false if control.raised? || candidate.raised?

      control.value[:status] == candidate.value[:status]
    end

    def ignore?(control, candidate)
      control.raised? || candidate.raised?
    end

    def raised(observation)
      (@raised_observations ||= []) << observation.slug
    end

    def publishable_value(observation)
      return if observation.raised?

      observation.value.merge(test: true)
    end

    def publish!(result)
      @publish_io = StringIO.new(JSON.generate(result.to_h))
    end

    def select_observation(result)
      context[:rollout] ? result.candidate : result.control
    end
  end

  def setup
    @experiment = TestExperiment.new("test-experiment")
    @control = LabCoat::Observation.new("control", @experiment) do
      @experiment.control
    end
  end

  def test_enabled?
    @experiment.instance_variable_set(:@context, { num: 1 })
    refute(@experiment.enabled?)
    @experiment.instance_variable_set(:@context, { num: 2 })
    assert(@experiment.enabled?)
    @experiment.instance_variable_set(:@context, {})
  end

  def test_compare
    candidate_match = LabCoat::Observation.new("candidate_match", @experiment) do
      { result: "def", status: :ok }
    end

    candidate_mismatch = LabCoat::Observation.new("candidate_mismatch", @experiment) do
      { result: "abc", status: :error }
    end

    assert(@experiment.compare(@control, candidate_match))
    refute(@experiment.compare(@control, candidate_mismatch))
  end

  def test_ignore?
    candidate_raise = LabCoat::Observation.new("candidate_raise", @experiment) do
      raise StandardError, "boom!"
    end

    assert(@experiment.ignore?(@control, candidate_raise))
  end

  def test_raised
    assert_nil(@experiment.raised_observations)
    @experiment.run!(num: 2) # even number to enable experiment
    refute_includes(@experiment.raised_observations, "test-experiment.control")
    assert_includes(@experiment.raised_observations, "test-experiment.candidate")
  end

  def test_publishable_value
    assert_equal(
      { result: "abc", status: :ok, test: true },
      @experiment.publishable_value(@control)
    )
  end

  def test_publish!
    @experiment.run!(num: 2)
    assert_match(/"experiment":"test-experiment"/, @experiment.publish_io.read)
  end

  def test_select_observation # rubocop:disable Metrics/MethodLength
    # Returns control even if rollout is true if not enabled.
    assert_equal(
      { result: "abc", status: :ok },
      @experiment.run!(rollout: true)
    )

    # Returns control if rollout is false, even if enabled.
    assert_equal(
      { result: "abc", status: :ok },
      @experiment.run!(rollout: false, num: 2)
    )

    # Returns candidate when rollout is true and is enabled.
    assert_nil(
      @experiment.run!(rollout: true, num: 2)
    )
  end

  def test_run!
    assert_equal(
      { result: "abc", status: :ok },
      @experiment.run!(num: 1)
    )
    assert_equal(
      { result: "abc", status: :ok },
      @experiment.run!(num: 2)
    )
  end
end

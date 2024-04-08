# frozen_string_literal: true

class TestObservation < Minitest::Test
  def setup
    @experiment = LabCoat::Experiment.new("test_experiment") do
      def publishable_value(observation) # rubocop:disable Lint/NestedMethodDefinition
        "publishable #{observation.value}"
      end
    end

    @observation = LabCoat::Observation.new("control", @experiment) do
      sleep(0.1)
      "success"
    end
  end

  def test_duration
    assert_operator(@observation.duration, :>=, 0.1)
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
end

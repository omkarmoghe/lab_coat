# frozen_string_literal: true

require_relative "lab_coat/version"
require_relative "lab_coat/observation"
require_relative "lab_coat/result"
require_relative "lab_coat/experiment"

module LabCoat
  Error = Class.new(StandardError)
  InvalidExperimentError = Class.new(Error)
end

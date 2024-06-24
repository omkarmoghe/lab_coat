## [0.1.7] - Unreleased
- Fixes bug where disabled `Experiments` would not reset the runtime context.

## [0.1.6] - 2024-06-17
- Adds [#1](https://github.com/omkarmoghe/lab_coat/issues/1)

## [0.1.5] - 2024-05-20
- Adds `select_observation` to allow users to control which `Observation` value is returned by the `Experiment`. This helps with controlled rollout.

## [0.1.4] - 2024-04-19
- Removes the arity check, it's not very intuitive
- Adds a `@context` that gets set at runtime and reset after each run. This is a much simpler way for methods to access a shared runtime context that can be set per `run!`.

## [0.1.3] - 2024-04-17
- Add an arity check that `Experiment` now enforces at runtime for the `#enabled?`, `control`, and `candidate` methods.

## [0.1.2] - 2024-04-15
- Adds `Benchmark` to capture the duration with more details.
- Adds `to_h` methods to `Result` and `Observation` for convenience.

## [0.1.1] - 2024-04-08
- Adds `#slug` method to `Observation`.

## [0.1.0] - 2024-04-08
- Initial release

## [0.1.5] - Unreleased
- Adds `select_observation` to allow users to control which observation value is returned by the experiment. This helps with controlled rollout.

## [0.1.4] - 2024-04-19
- Remove the arity check, it's not very intuitive
- Adds a `@context` that gets set at runtime and reset after each run. This is a much simpler way for methods to access a shared runtime context that can be set per `run!`.

## [0.1.3] - 2024-04-17
- `Experiment` now enforces arity at runtime for the `#enabled?`, `control`, and `candidate` methods.

## [0.1.2] - 2024-04-15
- use `Benchmark` to capture the duration with more details
- add `to_h` methods to `Result` and `Observation` for convenience

## [0.1.1] - 2024-04-08
- add `#slug` method to `Observation`

## [0.1.0] - 2024-04-08
- Initial release

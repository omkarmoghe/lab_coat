# LabCoat 🥼

![Gem Version](https://img.shields.io/gem/v/lab_coat) ![Gem Total Downloads](https://img.shields.io/gem/dt/lab_coat)

A simple experiment library to safely test new code paths. `LabCoat` is designed to be highly customizable and play nice with your existing tools/services.

This library is heavily inspired by [Scientist](https://github.com/github/scientist), with some key differences:
- `Experiments` are `classes`, not `modules` which means they are stateful by default.
- There is no app wide default experiment that gets magically set.
- The `Result` only supports one comparison at a time, i.e. only 1 `candidate` is allowed per run.

## Installation

Install the gem and add to the application's Gemfile by executing:

`bundle add lab_coat`

If bundler is not being used to manage dependencies, install the gem by executing:

`gem install lab_coat`

## Usage

### Create an `Experiment`

To do some science, i.e. test out a new code path, start by defining an `Experiment`. An experiment is any class that inherits from `LabCoat::Experiment` and implements the [required methods](#required-methods).

```ruby
# your_experiment.rb
class YourExperiment < LabCoat::Experiment
  def control
    expensive_query.first
  end

  def candidate
    refactored_version_of_the_query.first
  end

  def enabled?
    true
  end
end
```

The base initializer for an `Experiment` requires a `name` argument; it's a good idea to name your experiments.

#### Required methods

See the [`Experiment`](lib/lab_coat/experiment.rb) class for more details.

|Method|Description|
|---|---|
|`candidate`|The new behavior you want to test.|
|`control`|The existing or default behavior. This will always be returned from `#run!`.|
|`enabled?`|Returns a `Boolean` that controls whether or not the experiment runs.|
|`publish!`|This is not _technically_ required, but `Experiments` are not useful unless you can analyze the results. Override this method to record the `Result` however you wish.|

> [!TIP]
> The `#run!` method accepts arbitrary arguments and forwards them to `enabled?`, `control`, and `candidate` in case you need to provide data at runtime.

#### Additional methods

|Method|Description|
|---|---|
|`compare`|Whether or not the result is a match. This is how you can run complex/custom comparisons.|
|`ignore?`|Whether or not the result should be ignored. Ignored `Results` are still passed to `#publish!`|
|`raised`|Callback method that's called when an `Observation` raises.|

> [!TIP]
> You should create a shared base class(es) to maintain consistency across experiments within your app.

You might want to give your experiment some context, or state. You can do this via an initializer or writer methods just like any other Ruby class.

```ruby
# application_experiment.rb
class ApplicationExperiment < LabCoat::Experiment
  attr_reader :user, :is_admin

  def initialize(user)
    @user = user
    @is_admin = user.admin?
  end
end
```

You might want to `publish!` all experiments in a consistent way, so that you can analyze the data and make decisions. New `Experiment` authors should not have to redo the "plumbing" between your experimentation framework (e.g. `LabCoat`) and your observability (o11y) process.

```ruby
# application_experiment.rb
class ApplicationExperiment < LabCoat::Experiment
  def publish!(result)
    YourO11yService.track_experiment_result(
      name: result.experiment.name,
      matched: result.matched?,
      observations: {
        control: result.control.publishable_value,
        candidate: result.candidate.publishable_value,
      }
    )
  end
end
```

You might have a common way to enable experiments such as a feature flag system and/or common guards you want to enforce application wide. These might come from a mix of services and the `Experiment`'s state.

```ruby
# application_experiment.rb
class ApplicationExperiment < LabCoat::Experiment
  def enabled?
    !@is_admin && YourFeatureFlagService.flag_enabled?(@user.id, name)
  end
end
```

You might want to track any errors thrown from all your experiments and route them to some service, or log them.

```ruby
# application_experiment.rb
class ApplicationExperiment < LabCoat::Experiment
  def raised(observation)
    puts <<~MSG
      #{observation.slug} raised error: #{observation.error.class.name}
      #{observation.error.full_message}
    MSG
  end
end
```

### Make some `Observations` via `run!`

You don't have to create an `Observation` yourself; that happens automatically when you call `Experiment#run!`. The control and candidate `Observations` are packaged into a `Result` and [passed to `Experiment#publish!`](#publish-the-result).

|Attribute|Description|
|---|---|
|`duration`|The duration of the run in `float` seconds.|
|`error`|If the code path raised, the thrown exception is stored here.|
|`experiment`|The `Experiment` instance this `Result` is for.|
|`name`|Either `"control"` or `"candidate"`.|
|`publishable_value`|A publishable representation of the `value`, as defined by `Experiment#publishable_value`.|
|`raised?`|Whether or not the code path raised.|
|`slug`|A combination of the `Experiment#name` and `Observation#name`, e.g. `"experiment_name.control"`|
|`value`|The return value of the observed code path.|

`Observation` instances are passed to many of the `Experiment` methods that you may override.

```ruby
# your_experiment.rb
def compare(control, candidate)
  return false if control.raised? || candidate.raised?

  control.value.some_method == candidate.value.some_method
end

def ignore?(control, candidate)
  return true if control.raised? || candidate.raised?
  return true if candidate.value.some_guard?

  false
end

def publishable_value(observation)
  if observation.raised?
    {
      error_class: observation.error.class.name,
      error_message: observation.error.message
    }
  else
    {
      type: observation.name,
      value: observation.publishable_value,
      duration: observation.duration
    }
  end
end

# Elsewhere...
YourExperiment.new(...).run!
```

### Publish the `Result`

A `Result` represents a single run of an `Experiment`.

|Attribute|Description|
|---|---|
|`candidate`|An `Observation` instance representing the `Experiment#candidate` behavior|
|`control`|An `Observation` instance representing the `Experiment#control` behavior|
|`experiment`|The `Experiment` instance this `Result` is for.|
|`ignored?`|Whether or not the result should be ignored, as defined by `Experiment#ignore?`|
|`matched?`|Whether or not the `control` and `candidate` match, as defined by `Experiment#compare`|

The `Result` is passed to your implementation of `#publish!` when an `Experiment` is finished running.

```ruby
def publish!(result)
  if result.ignored?
    puts "🙈"
    return
  end

  if result.matched?
    puts "😎"
  else
    control = result.control
    candidate = result.candidate
    puts <<~MSG
      😮

      #{control.slug}
      Value: #{control.publishable_value}
      Duration: #{control.duration}
      Error: #{control.error&.message}

      #{candidate.slug}
      Value: #{candidate.publishable_value}
      Duration: #{candidate.duration}
      Error: #{candidate.error&.message}
    MSG
  end
end
```
Running a mismatched experiment with this implementation of `publish!` would produce:

```
😮

my_experiment.control
Value: 420
Duration: 12.934
Error:

my_experiment.candidate
Value: 69
Duration: 9.702
Error:
```

### Standalone `Observations`

The `Observation` class can be used as a standalone wrapper for any code that you want to experiment with. Instantiating an `Observation` automatically:
- measures the duration of the code block
- captures the return value of the code block
- rescues and stores any errors raised by the code block

```ruby
10.times do |i|
  observation = Observation.new("test-#{i}", nil) do
    some_code_path
  end

  puts "#{observation.name} results:"
  if observation.raised?
    puts "error: #{observation.error.message}"
  else
    puts <<~MSG
      duration: #{observation.duration}
      succeeded: #{!observation.raised?}
    MSG
  end
end
```

> [!WARNING]
> Be careful when using `Observation` instances without an `Experiment` set. Some methods like `#publishable_value` and `#slug` depend on an `experiment` and may raise an error when called.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/omkarmoghe/lab_coat.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

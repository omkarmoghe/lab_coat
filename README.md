# LabCoat 🥼

A simple experiment library to safely test new code paths.

This library is heavily inspired by [Scientist](https://github.com/github/scientist), with some key differences:
- `Experiments` are `classes`, not `modules` which means they are stateful by default.
- There is no app wide default experiment that gets magically set.
- The `Result` only support one comparison at a time, i.e. only 1 `candidate` is allowed.

## Installation

Install the gem and add to the application's Gemfile by executing:

`bundle add lab_coat`

If bundler is not being used to manage dependencies, install the gem by executing:

`gem install lab_coat`

## Usage

### Create an `Experiment`

<!-- TODO -->

### Make some `Observations` via `run!`

You don't have to create an `Observation` yourself; that happens automatically when you call `Experiment#run!`.

|Attribute|Description|
|---|---|
|`name`|Either `"control"` or `"candidate"`.|
|`experiment`|The `Experiment` instance this `Result` is for.|
|`duration`|The duration of the run in `float` seconds.|
|`value`|The return value of the observed code path.|
|`publishable_value`|A publishable representation of the `value`, as defined by `Experiment#publishable_value`.|
|`raised?`|Whether or not the code path raised.|
|`error`|If the code path raised, the thrown exception is stored here.|

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
experiment.run!
```

### Publish the `Result`

A `Result` represents a single run of an `Experiment`.

|Attribute|Description|
|---|---|
|`experiment`|The `Experiment` instance this `Result` is for.|
|`control`|An `Observation` instance representing the `Experiment#control` behavior|
|`candidate`|An `Observation` instance representing the `Experiment#candidate` behavior|
|`matched?`|Whether or not the `control` and `candidate` match, as defined by `Experiment#compare`|
|`ignored?`|Whether or not the result should be ignored, as defined by `Experiment#ignore?`|

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
    puts <<~MISMATCH
      😮

      [Control]
      Value: #{result.control.publishable_value}
      Duration: #{result.control.duration}
      Error: #{result.control.error&.message}

      [Candidate]
      Value: #{result.candidate.publishable_value}
      Duration: #{result.candidate.duration}
      Error: #{result.candidate.error&.message}
    MISMATCH
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lab_coat.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

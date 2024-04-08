# LabCoat 🥼

A simple experiment library to safely test new code paths.

This library is heavily inspired by [Scientist](https://github.com/github/scientist), with some key differences:
- `Experiments` are `classes`, not `modules` which means they are stateful by default.
- There is no app wide default experiment that gets magically set.
- The `Result` only support one comparison at a time, i.e. only 1 `candidate` is allowed.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lab_coat

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lab_coat

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lab_coat.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

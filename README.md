# Text2svg

Build svg path data from font file

Using by freetype API

```
$ text2svg "Hello, World\!" --font="/Library/Fonts/Times New Roman.ttf" > test.svg && open test.svg -a /Applications/Google\ Chrome.app
```

![img](https://raw.githubusercontent.com/ksss/text2svg/master/data/sample.jpg)

## Option

```shell
$ text2svg --help
Usage: text2svg [options]
    -f, --font FONT                  font file path (require)
        --text-align ALIGN           text align left,right or center (default left)
        --encoding ENCODING          input text encoding (default utf-8)
        --bold                       embolden outline (default false)
        --italic                     oblique outline (default false)
        --option STRING              decorate options (default nil)(e.g. fill="red" stroke-width="100")
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'text2svg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install text2svg

## Require

- libfreetype

see also http://www.freetype.org/

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/text2svg. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

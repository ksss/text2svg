# Text2svg

[![Build Status](https://travis-ci.org/ksss/text2svg.svg?branch=master)](https://travis-ci.org/ksss/text2svg)

Build svg path data from font file and text.

So, This tool can convert text to svg outline by font.

Using by freetype API.

```
$ text2svg "Hello, World\!" --font="/Library/Fonts/Times New Roman.ttf" > test.svg
$ open test.svg -a /Applications/Google\ Chrome.app
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
        --attribute STRING           decorate options (default nil)(e.g. fill="red" stroke-width="100")
```

## Feature

- Support kerning shift
- Support multi line
- Support decorated font
- Support `.ttf` and `.otf` font file (using by FreeType)
- And support text-align, **bold** and _italic_ effects

## Ruby API

```ruby
require 'text2svg'
puts Text2svg('Hello, World!', font: "/Library/Fonts/Times New Roman.ttf", text_align: :left, bold: true)
#=> "<svg ...>"
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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

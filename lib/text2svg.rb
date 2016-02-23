require 'text2svg/option'
require 'text2svg/typography'
require 'text2svg/version'

module Kernel
  def Text2svg(text, option)
    Text2svg::Typography.build(text, option)
  end
end

# frozen_string_literal: true
require 'freetype'

module Text2svg
  class Outline2d
    def initialize(outline)
      @path_data = outline.svg_path_data
    end

    def to_a
      @path_data
    end

    def to_d
      to_a.join(' ')
    end
  end
end

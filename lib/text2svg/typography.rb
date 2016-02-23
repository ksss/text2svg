require 'freetype'
require 'text2svg/option'

module Text2svg
  class OptionError < StandardError
  end

  class Typography
    WHITESPACE = /[[:space:]]/
    IDEOGRAPHIC_SPACE = /[\u{3000}]/
    NEW_LINE = /[\u{000A}]/
    NOTDEF_GLYPH_ID = 0
    INTER_CHAR_SPACE_DIV = 50r

    class << self
      def build(text, option)
        if Hash === option
          option = Option.from_hash(option)
        end
        content = path(text, option)
        svg = %(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 #{content.width} #{content.height}">\n)
        svg << "<title>#{text}</title>\n"
        svg << content.data
        svg << "</svg>\n"
        Content.new(svg, content.width, content.height, content.notdef_indexes)
      end

      def path(text, option)
        if Hash === option
          option = Option.from_hash(option)
        end
        text = String.try_convert(text)
        return Content.new('', 0, 0) if text.nil? || text.empty?

        option.encoding ||= Encoding::UTF_8
        option.text_align ||= :left
        text.force_encoding(option.encoding).encode!(Encoding::UTF_8)

        notdef_indexes = []
        unless option.font
          raise OptionError, 'should be set `font\' option'
        end
        FreeType::API::Font.open(File.expand_path(option.font)) do |f|
          f.set_char_size(0, 0, 3000, 3000)

          lines = []
          line = []
          lines << line
          first_hori_bearing_x = []

          space_width = f.glyph(' '.freeze).char_width
          text.each_char.with_index do |char, index|
            if NEW_LINE.match char
              line = []
              lines << line
              next
            end

            glyph_id = f.char_index(char)
            glyph = if glyph_id == 0
              notdef_indexes << index
              f.notdef
            else
              f.glyph(char)
            end

            if glyph.outline.tags.empty?
              notdef_indexes << index
              glyph = f.notdef
            end

            glyph.bold if option.bold
            glyph.italic if option.italic

            hori_advance, width, is_draw = if IDEOGRAPHIC_SPACE.match char
              [space_width * 2r, space_width * 2r, false]
            elsif WHITESPACE.match char
              [space_width, space_width, false]
            else
              if line.empty?
                first_hori_bearing_x << glyph.metrics[:horiBearingX]
              end
              [glyph.metrics[:horiAdvance], glyph.metrics[:width], true]
            end
            line << CharSet.new(char, hori_advance, width, is_draw, glyph.outline.svg_path_data)
          end

          inter_char_space = space_width / INTER_CHAR_SPACE_DIV

          width_by_line = lines.zip(first_hori_bearing_x).map do |(line, hori_bearing_x)|
            before_char = nil
            if line.empty?.!
              line.map { |cs|
                cs.width = if cs == line.last
                  [cs.width, cs.hori_advance].max
                else
                  cs.hori_advance
                end
                w = cs.width + f.kerning_unfitted(before_char, cs.char).x
                w.tap { before_char = cs.char }
              }.inject(:+) + (line.length - 1) * inter_char_space - [0, hori_bearing_x].min
            else
              0
            end
          end
          max_width = width_by_line.max

          y = 0r
          output = ''
          line_height = f.line_height

          output << %(<g #{option.attribute}>\n) if option.attribute

          lines.zip(width_by_line, first_hori_bearing_x).each do |(line, line_width, hori_bearing_x)|
            x = 0r
            y += line_height
            before_char = nil

            case option.text_align.to_sym
            when :center
              x += (max_width - line_width) / 2r
            when :right
              x += max_width - line_width
            when :left
              # nothing
            else
              warn 'text_align must be left,right or center'
            end

            output << %!<g transform="matrix(1,0,0,1,0,#{y.to_i})">\n!

            x -= hori_bearing_x
            line.each do |cs|
              x += f.kerning_unfitted(before_char, cs.char).x.to_i
              if cs.draw?
                output << %!  <path transform="matrix(1,0,0,1,#{x.to_i},0)" d="#{cs.outline2d.join(' '.freeze)}"/>\n!
              end
              x += cs.width
              x += inter_char_space if cs != line.last
              before_char = cs.char
            end
            output << "</g>\n".freeze
          end
          output << "</g>\n".freeze if option.attribute

          option_width = 0
          option_width += space_width / 1.5 if option.italic
          Content.new(output, (max_width + option_width).to_i, (y + line_height / 4).to_i, notdef_indexes)
        end
      end
    end
  end

  CharSet = Struct.new(:char, :hori_advance, :width, :is_draw, :outline2d) do
    def draw?
      is_draw
    end
  end

  Content = Struct.new(:data, :width, :height, :notdef_indexes) do
    def to_s
      data
    end
  end
end

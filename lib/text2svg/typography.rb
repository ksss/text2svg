require 'cgi'
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
        svg << "<title>#{CGI.escapeHTML(text.to_s)}</title>\n"
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
          raise OptionError, 'should set `font\' option'
        end
        char_sizes = option.char_size.split(',').map(&:to_i)
        unless char_sizes.length == 4
          raise OptionError, 'char-size option should be four integer values'
        end
        FreeType::API::Font.open(File.expand_path(option.font)) do |f|
          f.set_char_size(*char_sizes)

          lines = []
          line = []
          lines << line
          min_hori_bearing_x_by_line = [0]

          space_width = f.glyph(' '.freeze).char_width
          text.each_char.with_index do |char, index|
            if NEW_LINE.match char
              min_hori_bearing_x_by_line[-1] = min_hori_bearing_x(line)
              min_hori_bearing_x_by_line << 0
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

            metrics = FreeType::C::FT_Glyph_Metrics.new
            is_draw = if IDEOGRAPHIC_SPACE.match char
              metrics[:width] = space_width * 2r
              metrics[:height] = 0
              metrics[:horiBearingX] = space_width * 2r
              metrics[:horiBearingY] = 0
              metrics[:horiAdvance] = space_width * 2r
              metrics[:vertBearingX] = 0
              metrics[:vertBearingY] = 0
              metrics[:vertAdvance] = 0

              false
            elsif WHITESPACE.match char
              metrics[:width] = space_width
              metrics[:height] = 0
              metrics[:horiBearingX] = space_width
              metrics[:horiBearingY] = 0
              metrics[:horiAdvance] = space_width
              metrics[:vertBearingX] = 0
              metrics[:vertBearingY] = 0
              metrics[:vertAdvance] = 0

              false
            else
              FreeType::C::FT_Glyph_Metrics.members.each do |m|
                metrics[m] = glyph.metrics[m]
              end

              true
            end
            line << CharSet.new(char, metrics, is_draw, glyph.outline.svg_path_data)
          end

          min_hori_bearing_x_by_line[-1] = min_hori_bearing_x(line)
          inter_char_space = space_width / INTER_CHAR_SPACE_DIV
          min_hori_bearing_x_all = min_hori_bearing_x_by_line.min

          width_by_line = lines.map do |line|
            before_char = nil
            if line.empty?.!
              line.map { |cs|
                width = if cs.equal?(line.last)
                  cs.metrics[:width] + cs.metrics[:horiBearingX]
                else
                  cs.metrics[:horiAdvance]
                end
                w = width + f.kerning_unfitted(before_char, cs.char).x
                w.tap { before_char = cs.char }
              }.inject(:+) + (line.length - 1) * inter_char_space - min_hori_bearing_x_all
            else
              0
            end
          end
          max_width = width_by_line.max

          y = 0r
          output = ''
          output << %(<g #{option.attribute}>\n) if option.attribute

          lines.zip(width_by_line).each_with_index do |(line, line_width), index|
            x = 0r
            y += if index == 0
              f.face[:size][:metrics][:ascender]
            else
              f.line_height
            end
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

            x -= min_hori_bearing_x_all
            line.each do |cs|
              x += f.kerning_unfitted(before_char, cs.char).x.to_i
              if cs.draw?
                output << %!  <path transform="matrix(1,0,0,1,#{x.to_i},0)" d="#{cs.outline2d.join(' '.freeze)}"/>\n!
              end
              x += cs.metrics[:horiAdvance]
              x += inter_char_space if cs != line.last
              before_char = cs.char
            end
            output << "</g>\n".freeze
          end
          output << "</g>\n".freeze if option.attribute

          option_width = 0
          option_width += space_width / 1.5 if option.italic
          Content.new(
            output,
            (max_width + option_width).to_i,
            y.to_i - f.face[:size][:metrics][:descender] * 1.2,
            notdef_indexes
          )
        end
      end

      private

      def min_hori_bearing_x(line)
        return 0 if line.empty?
        point = 0
        bearings = line.map do |cs|
          (cs.metrics[:horiBearingX] + point).tap {
            point += cs.metrics[:horiAdvance]
          }
        end
        bearings.min
      end
    end
  end

  CharSet = Struct.new(:char, :metrics, :is_draw, :outline2d) do
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

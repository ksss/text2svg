require 'freetype'
require 'text2svg/outline2d'

module Text2svg
  class Typography
    WHITESPACE = /[[:space:]]/
    IDEOGRAPHIC_SPACE = /[\u{3000}]/
    NEW_LINE = /[\n]/
    NOTDEF_GLYPH_ID = 0
    INTER_CHAR_SPACE_DIV = 50r

    class << self
      def build(text, font:, stroke: :none, stroke_width: 1, fill: :black, text_align: :left, encoding: Encoding::UTF_8)
        g, w, h = path(
          text,
          font: font,
          stroke: stroke,
          stroke_width: stroke_width,
          fill: fill,
          text_align: text_align,
          encoding: encoding,
        )
        svg = %(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 #{w} #{h}">\n)
        svg << "<title>#{text}</title>\n"
        svg << g
        svg << "</svg>\n"
        svg
      end

      def path(text, font:, stroke: :none, stroke_width: 1, fill: :black, text_align: :left, encoding: Encoding::UTF_8)
        stroke ||= :none
        fill ||= :black
        text_align ||= :left
        text.force_encoding(encoding).encode!(Encoding::UTF_8)

        FreeType::API::Font.open(File.expand_path(font)) do |f|
          f.set_char_size(0, 0, 3000, 3000)

          lines = []
          line = []
          lines << line

          before_char = nil
          space_width = f.glyph(' '.freeze).char_width
          text.each_char do |char|
            if NEW_LINE.match char
              line = []
              lines << line
              before_char = nil
              next
            end

            # glyph登録されていない文字
            glyph_id = f.char_index(char)
            glyph = if glyph_id == 0
              f.notdef
            else
              f.glyph(char)
            end

            # glyphが登録されているが字形が登録されていない文字
            if glyph.outline.tags.length == 0
              glyph = f.notdef
            end
            kern = f.kerning_unfitted(before_char, char).x

            width, is_draw = if IDEOGRAPHIC_SPACE.match char
              [space_width * 2r, false]
            elsif WHITESPACE.match char
              [space_width, false]
            else
              [glyph.char_width, true]
            end
            before_char = char
            line << CharSet.new(char, width, is_draw, Outline2d.new(glyph.outline).to_d)
          end

          inter_char_space = space_width / INTER_CHAR_SPACE_DIV
          width_by_line = lines.map do |line|
            before_char = nil
            if 0 < line.length
              line.map { |cs|
                w = cs.width + f.kerning_unfitted(before_char, cs.char).x
                w.tap { before_char = cs.char }
              }.inject(:+) + (line.length - 1) * inter_char_space
            else
              0
            end
          end
          max_width = width_by_line.max

          y = 0r
          output = ''
          line_height = f.line_height
          lines.zip(width_by_line).each do |(line, line_width)|
            x = 0r
            y += line_height
            before_char = nil

            case text_align.to_sym
            when :center
              x += (max_width - line_width) / 2r
            when :right
              x += max_width - line_width
            when :left
              # nothing
            else
              warn 'text_align must be left,right or center'
            end

            output << %!<g transform="translate(0,#{y.to_i})">\n!

            line.each do |cs|
              x += f.kerning_unfitted(before_char, cs.char).x.to_i
              output << %!  <g transform="translate(#{x.to_i},0)">\n!
              if cs.draw?
                output << %(    <path stroke="#{stroke}" stroke-width="#{stroke_width}" fill="#{fill}" d="#{cs.d}"/>\n)
              end
              x += cs.width
              x += inter_char_space if cs != line.last
              output << "  </g>\n".freeze
              before_char = cs.char
            end
            output << "</g>\n".freeze
          end

          [output, max_width.to_i, (y + line_height / 4).to_i]
        end
      end
    end
  end

  CharSet = Struct.new(:char, :width, :is_draw, :d) do
    def draw?
      is_draw
    end
  end
end

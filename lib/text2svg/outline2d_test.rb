require 'text2svg/outline2d'

module Text2svgOutline2dTest
  def test_to_a(t)
    FreeType::API::Font.open('/Library/Fonts/Times New Roman.ttf') do |font|
      font.set_char_size(0, 0, 3000, 3000)
      glyph = font.glyph('a')
      outline2d = Text2svg::Outline2d.new(glyph.outline)
      a = outline2d.to_a
      unless Array === a || 0 < a.length
        t.error 'return value was break'
      end
    end
  end

  def test_to_d(t)
    FreeType::API::Font.open('/Library/Fonts/Times New Roman.ttf') do |font|
      font.set_char_size(0, 0, 3000, 3000)
      glyph = font.glyph('a')
      outline2d = Text2svg::Outline2d.new(glyph.outline)

      d = outline2d.to_d
      unless String === d || 0 < d.length
        t.error 'return value was break'
      end
    end
  end
end

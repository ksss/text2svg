require 'text2svg/typography'

module Text2svgTypographyTest
  def test_build(t)
    c = Text2svg::Typography.build(nil, Text2svg::Option.new)
    unless Text2svg::Content === c
      t.error('return value was break')
    end

    begin
      Text2svg::Typography.build('a', Text2svg::Option.new)
    rescue Text2svg::OptionError
    else
      t.error('error conditions was changed')
    end

    opt = Text2svg::Option.new(
      '/Library/Fonts/Times New Roman.ttf',
      nil,
    )
    [nil, :left, :right, :center].each do |text_align|
      opt.text_align = text_align
      [Encoding::UTF_8, Encoding::ASCII_8BIT].each do |encoding|
        opt.encoding = encoding
        [nil, 'fill="red"'].each do |attribute|
          opt.attribute = attribute
          [false, true].each do |bold|
            opt.bold = bold
            [false, true].each do |italic|
              opt.italic = italic
              ['ABC', "\n", "\n\nA", "", "A\nB\n\n", "A\n\n\nC"].each do |text|
                begin
                  c = Text2svg::Typography.build(text, opt)
                rescue => e
                  t.log("raise error #{e.class}: #{e.message} with text=\"#{text}\",opt=#{opt}")
                  raise
                end

                unless Text2svg::Content === c
                  t.error('return value was break')
                end

                unless c.data.encoding == Encoding::UTF_8
                  t.error('encoding was changed')
                end
              end
            end
          end
        end
      end
    end
  end

  def test_path(t)
    c = Text2svg::Typography.path(nil, Text2svg::Option.new)
    unless Text2svg::Content === c
      t.error('return value was break')
    end
  end

  def benchmark_build(b)
    str = [*'!'..'z'].join
    opt = Text2svg::Option.new('/Library/Fonts/Times New Roman.ttf')
    b.reset_timer
    i = 0
    while i < b.n
      Text2svg::Typography.build(str, opt)
      i += 1
    end
  end
end

require 'text2svg/typography'

module Text2svgTypographyTest
  def check(t, opt)
    ['ABC', "\n", "\n\nA", "", "A\nB\n\n", "A\n  \n\nC", "<", ">", "&", "=", "@", "%", "#", "("].each do |text|
      begin
        c = Text2svg::Typography.build(text, opt)
      rescue => e
        t.log("raise error #{e.class}: #{e.message} with text=\"#{text}\",opt=#{opt}")
        raise
      end

      unless Text2svg::Content === c
        t.error('return value was break')
      end

      unless Integer === c.width
        t.error('return value was break')
      end

      unless Integer === c.height
        t.error('return value was break')
      end
      unless Array === c.notdef_indexes
        t.error('return value was break')
      end

      unless c.data.encoding == Encoding::UTF_8
        t.error('encoding was changed')
      end
    end
  end

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

    Dir["data/*"].grep(/otf|ttf/).each do |font|
      [nil, :left, :right, :center].each do |text_align|
        [Encoding::UTF_8, Encoding::ASCII_8BIT].each do |encoding|
          [nil, 'fill="red"'].each do |attribute|
            [false, true].each do |bold|
              [false, true].each do |italic|
                ["0,0,0,0", "128,128,100,100"].each do |char_size|
                  [1, 0.02].each do |scale|
                    opt = Text2svg::Option.default
                    opt.font = font
                    opt.text_align = text_align
                    opt.encoding = encoding
                    opt.attribute = attribute
                    opt.bold = bold
                    opt.italic = italic
                    opt.char_size = char_size
                    opt.scale = scale
                    check(t, opt)
                  end
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
    opt = Text2svg::Option.default
    opt.font = 'data/sporq.ttf'
    b.reset_timer
    i = 0
    while i < b.n
      Text2svg::Typography.build(str, opt)
      i += 1
    end
  end
end

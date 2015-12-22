require 'text2svg/cli'

module Text2svgCLITest
  def check(t)
    out = capture do
      Text2svg::CLI.start
    end
    unless String === out
      t.error 'return value was break'
    end
    unless 0 < out.length
      t.error 'unsupported font?'
    end
    if out.strip[0, 4] != '<svg'
      t.error 'output format was break'
    end
  end

  def test_start(t)
    %w(left right center).each do |text_align|
      ARGV[0] = "Hello,\nWorld!"
      ARGV[1] = '--font=/Library/Fonts/Times New Roman.ttf'
      ARGV[2] = "--text-align=#{text_align}"

      check(t)
    end
  end

  def test_encoding(t)
    [
      ['utf-8', "\xEF\x82\x9B".force_encoding(Encoding::ASCII_8BIT)],
      ['utf-32', "\x00\x00\xFE\xFF\x00\x00\xF0\x9B".force_encoding(Encoding::ASCII_8BIT)],
    ].each do |(encoding, text)|
      ARGV[0] = text
      ARGV[1] = '--font=~/Library/Fonts/fontawesome-webfont.ttf'
      ARGV[2] = "--encoding=#{encoding}"
      check(t)
    end
  end

  def test_bold(t)
    ARGV[0] = 'Hello'
    ARGV[1] = '--font=/Library/Fonts/Times New Roman.ttf'
    ARGV[2] = '--bold'
    check(t)
  end

  def test_italic(t)
    ARGV[0] = 'Hello'
    ARGV[1] = '--font=/Library/Fonts/Times New Roman.ttf'
    ARGV[2] = '--italic'
    check(t)
  end

  def capture
    out = StringIO.new
    orig = $stdout
    $stdout = out
    yield
    out.string.dup
  ensure
    $stdout = orig
  end
end

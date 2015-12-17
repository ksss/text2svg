require 'text2svg/cli'

module Text2svgCLITest
  def test_start(t)
    ARGV[0] = 'abc'
    ARGV[1] = '--font=/Library/Fonts/Times New Roman.ttf'
    out = capture do
      Text2svg::CLI.start
    end
    unless String === out
      t.error 'return value was break'
    end
    unless 0 < out.length
      t.error 'unsupported font?'
    end
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

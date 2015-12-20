require 'text2svg/typography'

module Text2svg
  module CLI
    def start
      o = Option.new(
        nil,
        :left,
        :black,
        :none,
        1,
        Encoding::UTF_8,
      )
      OptionParser.new.tap { |opt|
        opt.on('-f', '--font FONT', 'font file path (require)') do |arg|
          o.font = arg
        end
        opt.on('--text-align ALIGN', 'text align left,right or center (default left)', %i(left right center)) do |arg|
          o.text_align = arg
        end
        opt.on('--fill FILL', 'text fill color (default black)') do |arg|
          o.fill = arg
        end
        opt.on('--encoding ENCODING', 'input text encoding (default utf-8)') do |arg|
          o.encoding = Encoding.find(arg)
        end
      }.parse!(ARGV)
      unless o.font
        raise ArgumentError, "require `--font` cli option. see --help"
      end
      text = ARGV[0] || $stdin.read
      puts Text2svg::Typography.build(text, o)
    end
    module_function :start
  end
end

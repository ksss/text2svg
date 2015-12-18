require 'text2svg/typography'

module Text2svg
  module CLI
    Option = Struct.new(:font, :text_align)

    def start
      o = CLI::Option.new
      OptionParser.new.tap { |opt|
        opt.on('-f', '--font [FONT]', 'font file path (require)') do |arg|
          o.font = arg
        end
        opt.on('--text-align [ALIGN]', 'text align left,right or center (default left)') do |arg|
          o.text_align = arg
        end
      }.parse!(ARGV)
      text = ARGV[0] || $stdin.read
      puts Text2svg::Typography.build(text, font: o.font, text_align: o.text_align)
    end
    module_function :start
  end
end

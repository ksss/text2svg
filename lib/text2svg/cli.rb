require 'text2svg/typography'

module Text2svg
  module CLI
    Option = Struct.new(:font)

    def start
      o = CLI::Option.new
      OptionParser.new.tap { |opt|
        opt.on('-f', '--font [FONT]', 'font file path (require)') do |arg|
          o.font = arg
        end
      }.parse!(ARGV)
      text = ARGV[0] || $stdin.read
      puts Text2svg::Typography.build(text, font: o.font)
    end
    module_function :start
  end
end

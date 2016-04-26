require 'optparse'
require 'text2svg/typography'
require 'text2svg/option'

module Text2svg
  module CLI
    def start
      # defaults
      o = Option.default

      OptionParser.new.tap { |opt|
        opt.on('-f', '--font FONT', 'font file path (require)') do |arg|
          o.font = arg
        end
        opt.on('--text-align ALIGN', 'text align left,right or center (default left)', %i(left right center)) do |arg|
          o.text_align = arg
        end
        opt.on('--encoding ENCODING', 'input text encoding (default utf-8)') do |arg|
          o.encoding = Encoding.find(arg)
        end
        opt.on('--bold', 'embolden outline (default false)') do |arg|
          o.bold = arg
        end
        opt.on('--italic', 'oblique outline (default false)') do |arg|
          o.italic = arg
        end
        opt.on('--attribute STRING', 'decorate options (default nil)(e.g. fill="red" stroke-width="100")') do |arg|
          o.attribute = arg
        end
        opt.on('--char-size WCHAR,HCHAR,HDPI,VDPI', 'char size set (default "0,0,3000,3000")') do |arg|
          o.char_size = arg
        end
        opt.on('--scale NUM', 'scale (default 1)', Numeric) do |arg|
          o.scale = arg
        end
      }.parse!(ARGV)
      unless o.font
        raise ArgumentError, 'require `--font` cli option. see --help'
      end
      text = ARGV[0] || $stdin.read
      puts Text2svg::Typography.build(text.dup, o).to_s
    end
    module_function :start
  end
end

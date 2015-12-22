require 'text2svg/typography'
require 'text2svg/option'

module Text2svg
  module CLI
    def start
      o = Option.new(
        nil,             # font
        :left,           # text_align
        :black,          # fill
        :none,           # stroke
        1,               # stroke_width
        Encoding::UTF_8, # encoding
        :none,           # stroke
        1,               # stroke_width
        false,           # bold
        false,           # italic
      )
      OptionParser.new.tap { |opt|
        opt.on('-f', '--font FONT', 'font file path (require)') do |arg|
          o.font = arg
        end
        opt.on('--text-align ALIGN', 'text align left,right or center (default left)', %i(left right center)) do |arg|
          o.text_align = arg
        end
        opt.on('--fill COLOR', 'text fill color (default black)') do |arg|
          o.fill = arg
        end
        opt.on('--encoding ENCODING', 'input text encoding (default utf-8)') do |arg|
          o.encoding = Encoding.find(arg)
        end
        opt.on('--stroke COLOR', 'stroke color setting (default none)') do |arg|
          o.stroke = arg
        end
        opt.on('--stroke-width NUM', 'stroke-width value (default 1)') do |arg|
          o.stroke_width = arg
        end
        opt.on('--bold', 'embolden outline (default false)') do |arg|
          o.bold = arg
        end
        opt.on('--italic', 'oblique outline (default false)') do |arg|
          o.italic = arg
        end
      }.parse!(ARGV)
      unless o.font
        raise ArgumentError, 'require `--font` cli option. see --help'
      end
      text = ARGV[0] || $stdin.read
      puts Text2svg::Typography.build(text, o).to_s
    end
    module_function :start
  end
end

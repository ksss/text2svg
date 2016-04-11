module Text2svg
  class Option < Struct.new(
    :font,
    :text_align,
    :encoding,
    :bold,
    :italic,
    :attribute,
    :char_size,
  )
    DEFAULTS = [
      nil,             # font
      :left,           # text_align
      Encoding::UTF_8, # encoding
      false,           # bold
      false,           # italic
      nil,             # attribute
      "0,0,3000,3000", # char_size
    ]

    class << self
      def from_hash(h)
        o = new(*DEFAULTS)
        h.to_h.each do |k, v|
          o[k.to_sym] = v
        end
        o
      end

      def default
        new(*DEFAULTS)
      end
    end
  end
end

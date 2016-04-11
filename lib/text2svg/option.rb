module Text2svg
  class Option < Struct.new(
    :font,
    :text_align,
    :encoding,
    :bold,
    :italic,
    :attribute,
  )
    DEFAULTS = [
      nil,             # font
      :left,           # text_align
      Encoding::UTF_8, # encoding
      false,           # bold
      false,           # italic
      nil,             # attribute
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

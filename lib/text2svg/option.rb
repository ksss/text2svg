module Text2svg
  class Option < Struct.new(
    :font,
    :text_align,
    :fill,
    :stroke,
    :stroke_width,
    :encoding,
    :stroke,
    :stroke_width,
  )

    class << self
      def from_hash(h)
        o = new
        h.to_h.each do |k, v|
          o[k.to_sym] = v
        end
        o
      end
    end
  end
end

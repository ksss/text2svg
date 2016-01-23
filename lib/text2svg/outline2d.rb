# frozen_string_literal: true
require 'freetype'

module Text2svg
  class Outline2d
    def initialize(outline)
      @outline = outline
    end

    def to_d
      end_ptd_of_counts = @outline.contours
      contours = []
      contour = []
      @outline.points.each.with_index do |point, index|
        contour << point
        if index == end_ptd_of_counts.first
          end_ptd_of_counts.shift
          contours << contour
          contour = []
        end
      end

      path = []
      contours.each do |contour|
        first_pt = contour.first
        last_pt = contour.last
        curve_pt = nil
        start = 0
        if first_pt.on_curve?
          curve_pt = nil
          start = 1
        else
          first_pt = if last_pt.on_curve?
            last_pt
          else
            FreeType::API::Point.new(0, (first_pt.x + last_pt.x) / 2, (first_pt.y + last_pt.y) / 2)
          end
          curve_pt = first_pt
        end
        path << ['M', first_pt.x, -first_pt.y]

        prev_pt = nil
        (start...contour.length).each do |j|
          pt = contour[j]
          prev_pt = if j == 0
            first_pt
          else
            contour[j - 1]
          end

          if prev_pt.on_curve? && pt.on_curve?
            path << ['L', pt.x, -pt.y]
          elsif prev_pt.on_curve? && !pt.on_curve?
            curve_pt = pt
          elsif !prev_pt.on_curve? && !pt.on_curve?
            path << ['Q', prev_pt.x, -prev_pt.y, (prev_pt.x + pt.x) / 2, -((prev_pt.y + pt.y) / 2)]
            curve_pt = pt
          elsif !prev_pt.on_curve? && pt.on_curve?
            path << ['Q', curve_pt.x, -curve_pt.y, pt.x, -pt.y]
            curve_pt = nil
          else
            raise
          end
        end

        next unless first_pt != last_pt
        path << if curve_pt
                  ['Q', curve_pt.x, -curve_pt.y, first_pt.x, -first_pt.y]
                else
                  ['L', first_pt.x, -first_pt.y]
        end
      end
      path << ['z'] if 0 < path.length

      path.map { |(command, *args)|
        "#{command}#{args.join(' ')}"
      }.join('')
    end
  end
end

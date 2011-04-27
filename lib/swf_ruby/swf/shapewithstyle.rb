#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Shapewithstyle
      attr_accessor :shape_version
      attr_accessor :fill_styles_with_offset
      attr_accessor :after_line_styles

      def initialize(bytearray, shape_version)
        @shape_version = shape_version
        fill_style_count = bytearray[0, 1].unpack("C").first
        offset = 1
        if fill_style_count == 255
          fill_style_count = bytearray[1, 2].unpack("v").first
          offset += 2
        end
        @fill_styles_with_offset = {}
        fill_style_count.times do
          fill_style = SwfRuby::Swf::Fillstyle.new(bytearray[offset..-1], @shape_version)
          @fill_styles_with_offset[offset] = fill_style
          offset += fill_style.length
        end
        # TODO after_line_styles are including outside tag data..
        @after_line_styles = bytearray[offset..-1]
        self
      end
    end
  end
end

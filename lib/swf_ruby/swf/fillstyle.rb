#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Fillstyle
      attr_accessor :shape_version
      attr_accessor :fill_style_type
      attr_accessor :color
      attr_accessor :gradient_matrix
      attr_accessor :gradient
      attr_accessor :bitmap_id
      attr_accessor :bitmap_id_offset
      attr_accessor :bitmap_matrix
      attr_reader :length

      def initialize(bytearray, shape_version)
        @shape_version = shape_version
        @fill_style_type = bytearray[0, 1].unpack("C").first
        offset = 1
        if @fill_style_type == 0x00
          if @shape_version >= 3
            @color = SwfRuby::Swf::Rgba.new(bytearray[offset..-1])
          else
            @color = SwfRuby::Swf::Rgb.new(bytearray[offset..-1])
          end
          offset += @color.length
        end
        if @fill_style_type == 0x10 or @fill_style_type == 0x12 or @fill_style_type == 0x13
          @gradient_matrix = SwfRuby::Swf::Matrix.new(bytearray[offset..-1])
          offset += @gradient_matrix.length
        end
        if @fill_style_type == 0x10 or @fill_style_type == 0x12
          @gradient = SwfRuby::Swf::Gradient.new(bytearray[offset..-1], @shape_version)
          offset += @gradient.length
        elsif @fill_style_type == 0x13
          @gradient = SwfRuby::Swf::Focalgradient.new(bytearray[offset..-1], @shape_version)
          offset += @gradient.length
        end
        if @fill_style_type == 0x40 or @fill_style_type == 0x41 or @fill_style_type == 0x42 or @fill_style_type == 0x43
          @bitmap_id = bytearray[offset, 2].unpack("v").first
          @bitmap_id_offset = offset
          offset += 2
          @bitmap_matrix = SwfRuby::Swf::Matrix.new(bytearray[offset..-1])
          offset += @bitmap_matrix.length
        end
        @length = offset
        self
      end
    end
  end
end

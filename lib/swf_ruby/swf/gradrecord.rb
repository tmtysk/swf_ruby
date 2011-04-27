#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Gradrecord
      attr_accessor :shape_version
      attr_accessor :ratio
      attr_accessor :color
      attr_reader :length

      def initialize(bytearray, shape_version)
        @shape_version = shape_version
        @ratio = bytearray[0, 1].unpack("C").first
        offset = 1
        if @shape_version >= 3
          @color = SwfRuby::Swf::Rgba.new(bytearray[offset..-1])
        else
          @color = SwfRuby::Swf::Rgb.new(bytearray[offset..-1])
        end
        offset += @color.length
        @length = offset
        self
      end
    end
  end
end

#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Header
      attr_accessor :compressed
      attr_accessor :version
      attr_accessor :file_length
      attr_accessor :frame_size
      attr_accessor :frame_rate
      attr_accessor :frame_count
      attr_reader :length

      def initialize(swf)
        # check if compressed
        if swf[1].chr == "W" and swf[2].chr == "S"
          if swf[0].chr == "F"
            @compressed = false
          elsif swf[0].chr == "C"
            @compressed = true
          end
        end
        # version
        @version = swf[3].chr.unpack("C").first
        # file size
        @file_length = swf[4, 4].unpack("V").first
        # frame size
        @frame_size = Rectangle.new(swf[8..-1])
        # frame rate
        @frame_rate = (swf[8+@frame_size.length].chr.unpack("C").first).to_f / 0x100
        @frame_rate += swf[9+@frame_size.length].chr.unpack("C").first
        # frame count
        @frame_count = swf[10+@frame_size.length, 2].unpack("v").first
        # header length
        @length = 12+@frame_size.length
      end
    end
  end
end

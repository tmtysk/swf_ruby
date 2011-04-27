#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Rgba
      attr_accessor :red
      attr_accessor :green
      attr_accessor :blue
      attr_accessor :alpha
      attr_reader :length

      def initialize(bytearray)
        @red = bytearray[0, 1].unpack("C").first
        @green = bytearray[1, 1].unpack("C").first
        @blue = bytearray[2, 1].unpack("C").first
        @alpha = bytearray[3, 1].unpack("C").first
        @length = 4
        self
      end
    end
  end
end

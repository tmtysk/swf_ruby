#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Rectangle
      attr_accessor :bits
      attr_accessor :xmin
      attr_accessor :xmax
      attr_accessor :ymin
      attr_accessor :ymax
      attr_reader :length

      def initialize(bytearray)
        @bits = bytearray[0].chr.unpack("B5").first.to_i(2)
        rect_bitstr = bytearray[0..((self.bits/2)+1)].unpack("B*").first
        @xmin = rect_bitstr[5, self.bits].to_i(2)
        @xmax = rect_bitstr[5+self.bits, self.bits].to_i(2)
        @ymin = rect_bitstr[5+2*self.bits, self.bits].to_i(2)
        @ymax = rect_bitstr[5+3*self.bits, self.bits].to_i(2)
        @length = (5+self.bits*4)/8+1 # including padded byte
      end
    end
  end
end

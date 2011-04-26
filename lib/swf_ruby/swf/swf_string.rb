#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class SwfString
      attr_accessor :string
      attr_reader :length # including StringEndMark

      def initialize(bytearray)
        @length = 0
        bytearray.each_byte do |byte|
          break if byte == 0
          @length += 1
        end
        @string = bytearray[0, @length]
        @length += 1 # Endmark
        self
      end
    end
  end
end

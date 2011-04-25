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
      attr_accessor :length

      def self.parse(swf)
        header = Header.new
        # check if compressed
        if swf[1].chr == "W" and swf[2].chr == "S"
          if swf[0].chr == "F"
            header.compressed = false
          elsif swf[0].chr == "C"
            header.compressed = true
          end
        end
        # version
        header.version = swf[3].chr.unpack("C").first
        # file size
        header.file_length = swf[4, 4].unpack("V").first

        # Zlib inflate
        if header.compressed
          swf[8..-1] = Zlib::Inflate.inflate(swf[8..-1])
        end

        # frame size
        header.frame_size = Rectangle.new(swf[8..-1])
        # frame rate
        header.frame_rate = (swf[8+header.frame_size.length].chr.unpack("C").first).to_f / 0x100
        header.frame_rate += swf[9+header.frame_size.length].chr.unpack("C").first
        # frame count
        header.frame_count = swf[10+header.frame_size.length, 2].unpack("v").first
        # header length
        header.length = 12+header.frame_size.length

        [header, swf]
      end
    end
  end
end

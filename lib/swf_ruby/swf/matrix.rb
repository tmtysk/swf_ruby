#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Matrix
      attr_accessor :has_scale
      attr_accessor :n_scale_bits
      attr_accessor :scale_x
      attr_accessor :scale_y
      attr_accessor :has_rotate
      attr_accessor :n_rotate_bits
      attr_accessor :rotate_skew_0
      attr_accessor :rotate_skew_1
      attr_accessor :n_translate_bits
      attr_accessor :translate_x
      attr_accessor :translate_y
      attr_reader :length

      def initialize(bytearray)
        bits_str = bytearray.unpack("B*").first
        @has_scale = bits_str.to_i(2)
        offset = 1
        if @has_scale == 1
          @n_scale_bits = bits_str[offset, 5].to_i(2)
          offset += 5
          @scale_x = bits_str[offset, self.n_scale_bits].to_i(2)
          @scale_y = bits_str[offset+self.n_scale_bits, self.n_scale_bits].to_i(2)
          offset += 2 * self.n_scale_bits
        end
        @has_rotate = bits_str[offset].to_i(2)
        offset += 1
        if @has_rotate == 1
          @n_rotate_bits = bits_str[offset, 5].to_i(2)
          offset += 5
          @rotate_skew_0 = bits_str[offset, self.n_rotate_bits].to_i(2)
          @rotate_skew_1 = bits_str[offset+self.n_rotate_bits, self.n_rotate_bits].to_i(2)
          offset += 2 * self.n_rotate_bits
        end
        @n_translate_bits = bits_str[offset, 5].to_i(2)
        offset += 5
        @translate_x = bits_str[offset, self.n_translate_bits].to_i(2)
        @translate_y = bits_str[offset+self.n_translate_bits, self.n_translate_bits].to_i(2)
        offset += 2 * self.n_translate_bits
        @length = offset
        self
      end
    end
  end
end

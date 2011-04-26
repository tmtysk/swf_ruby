#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Cxformwithalpha
      attr_accessor :has_add_terms
      attr_accessor :has_mult_terms
      attr_accessor :nbits
      attr_accessor :red_mult_term
      attr_accessor :green_mult_term
      attr_accessor :blue_mult_term
      attr_accessor :alpha_mult_term
      attr_accessor :red_add_term
      attr_accessor :green_add_term
      attr_accessor :blue_add_term
      attr_accessor :alpha_add_term
      attr_reader :length # byte_aligned

      def initialize(bytearray)
        bits_str = bytearray.unpack("B*").first
        @has_add_terms = bits_str[0].to_i(2)
        @has_mult_terms = bits_str[1].to_i(2)
        @nbits = bits_str[2, 4].to_i(2)
        offset = 6
        if @has_mult_terms == 1
          # TODO to get as signed bit values!!
          @red_mult_term = bits_str[offset, @nbits].to_i(2)
          @green_mult_term = bits_str[offset+@nbits, @nbits].to_i(2)
          @blue_mult_term = bits_str[offset+2*@nbits, @nbits].to_i(2)
          @alpha_mult_term = bits_str[offset+3*@nbits, @nbits].to_i(2)
          offset += 4 * @nbits
        end
        if @has_add_terms == 1
          # TODO to get as signed bit values!!
          @red_add_term = bits_str[offset, @nbits].to_i(2)
          @green_add_term = bits_str[offset+@nbits, @nbits].to_i(2)
          @blue_add_term = bits_str[offset+2*@nbits, @nbits].to_i(2)
          @alpha_add_term = bits_str[offset+3*@nbits, @nbits].to_i(2)
          offset += 4 * @nbits
        end
        @length = offset >> 3
        @length += 1 if offset & 7 > 0
        self
      end
    end
  end
end

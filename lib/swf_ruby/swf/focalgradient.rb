#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Focalgradient
      attr_accessor :shape_version
      attr_accessor :spread_mode
      attr_accessor :interpolation_mode
      attr_accessor :num_gradients
      attr_accessor :gradient_records
      attr_accessor :focal_point
      attr_reader :length

      def initialize(bytearray, shape_version)
        @shape_version = shape_version
        bits_str = bytearray[0, 1].unpack("B*").first
        @spread_mode = bits_str[0, 2].to_i(2)
        @interpolation_mode = bits_str[2, 2].to_i(2)
        @num_gradients = bits_str[4, 4].to_i(2)
        offset = 1
        @gradient_records = []
        @num_gradients.times do
          gradient_record = SwfRuby::Swf::Gradrecord.new(bytearray[offset..-1], @shape_version)
          @gradient_records << gradient_record
          offset += gradient_record.length
        end
        # TODO focal_point to be 8bit.8bit fixed_point number.
        @focal_point = bytearray[offset, 2]
        offset += 2
        @length = offset
        self
      end
    end
  end
end

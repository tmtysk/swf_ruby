#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Fillstyle
      attr_accessor :fill_style_type
      attr_accessor :color
      attr_accessor :gradient_matrix
      attr_accessor :gradient
      attr_accessor :bitmap_id
      attr_accessor :bitmap_id_offset
      attr_accessor :bitmap_matrix

      def initialize(bytearray)
        # TODO reading RGB, RGBA, GRADIENT and FOCALGRANDIENT, setting instance variables
        self
      end
    end
  end
end

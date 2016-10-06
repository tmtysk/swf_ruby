#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class BitsLossless2
      attr_accessor :format, :width, :height, :color_table_size, :zlib_bitmap_data

      ShiftDepth = Magick::MAGICKCORE_QUANTUM_DEPTH - 8
      MaxRGB = 2 ** Magick::MAGICKCORE_QUANTUM_DEPTH - 1

      def initialize(image_bytearray)
        image = Magick::Image.from_blob(image_bytearray).first
        data = ""
        data.force_encoding("ASCII-8BIT") if data.respond_to? :force_encoding
        @format = nil
        colormap = []
        # creating colormap to check number of colors
        image.get_pixels(0, 0, image.columns, image.rows).each_with_index do |pixel,i|
          break if colormap.length > 256
          idx = colormap.index(pixel)
          if idx
            data << [idx].pack("C")
          else
            colormap << pixel
            data << [colormap.length-1].pack("C")
          end
          if (i+1) % image.columns == 0
            # padding
            data += [0].pack("C") * (4-image.columns&3)
          end
        end

        # checking image format by size of colormap
        if colormap.length > 256
          # format=5
          # reset and re-build data_stream without colopmap
          data = ""
          image.get_pixels(0, 0, image.columns, image.rows).each_with_index do |pixel,i|
            opacity = (MaxRGB-pixel.opacity) >> ShiftDepth
            data += [opacity].pack("C")
            data += [pixel.red >> ShiftDepth].pack("C")
            data += [pixel.green >> ShiftDepth].pack("C")
            data += [pixel.blue >> ShiftDepth].pack("C")
          end
          @format = 5
        else
          # format=3
          # added colormap before data_stream
          data = colormap.inject("") { |r,c|
            opacity = (MaxRGB-c.opacity) >> ShiftDepth
            if opacity == 0
              r +=
                [0].pack("C") +
                [0].pack("C") +
                [0].pack("C") +
                [opacity].pack("C")
            else
              r +=
                [c.red >> ShiftDepth].pack("C") +
                [c.green >> ShiftDepth].pack("C") +
                [c.blue >> ShiftDepth].pack("C") +
                [opacity].pack("C")
            end
          } + data
          @format = 3
          @color_table_size = colormap.length-1
        end

        @width = image.columns
        @height = image.rows
        @zlib_bitmap_data = Zlib::Deflate.deflate(data)
      end
    end
  end
end

#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class Tag
      attr_reader :rawdata
      attr_reader :code
      attr_reader :length
      attr_reader :long_header
      attr_reader :data
      attr_reader :character_id
      attr_reader :refer_character_id
      attr_reader :refer_character_id_offset
      attr_reader :refer_character_inst_name

      def initialize(swf)
        swf.force_encoding("ASCII-8BIT") if swf.respond_to? :force_encoding
        record_header = swf[0, 2].unpack("v").first
        # tag type
        @code = (record_header >> 6) & 1023
        # tag length (including record header)
        @length = record_header & 63
        @long_header = false
        @data = nil
        if @length == 63
          len = swf[2, 4].unpack("i").first
          @data = swf[6, len]
          @length = len + 6
          @long_header = true
        else
          @data = swf[2, @length]
          @length += 2
        end
        @character_id = nil
        if self.define_tag?
          @character_id = @data[0, 2].unpack("v").first
        end
        @refer_character_id = nil
        @refer_character_id_offset = nil
        @refer_character_inst_name = nil
        data_offset = @long_header ? 6 : 2
        case Swf::TAG_TYPE[@code]
        when "PlaceObject"
          @refer_character_id_offset = data_offset
          @refer_character_id = @data[0, 2].unpack("v").first
        when "PlaceObject2"
          flags = @data[0].unpack("C").first
          offset = 3
          if flags & 2 == 2
            @refer_character_id_offset = data_offset + offset
            @refer_character_id = @data[offset, 2].unpack("v").first
            offset += 2
          end
          if flags & 32 == 32
            if flags & 4 == 4
              matrix = SwfRuby::Swf::Matrix.new(@data[offset..-1])
              offset += matrix.length
            end
            if flags & 8 == 8
              cxtfm = SwfRuby::Swf::Cxformwithalpha.new(@data[offset..-1])
              offset += cxtfm.length
            end
            offset += 2 if flags & 16 == 16
            @refer_character_inst_name = SwfRuby::Swf::SwfString.new(@data[offset..-1]).string
          end
        when "PlaceObject3"
          flags = @data[0, 2].unpack("n").first
          offset = 4
          if flags & 8 == 8
            class_name = SwfRuby::Swf::SwfString.new(@data[offset..-1])
            offset += class_name.length
          end
          if flags & 512 == 512
            @refer_character_id_offset = data_offset + offset
            @refer_character_id = @data[offset, 2].unpack("v").first
          end
          if flags & 8192 == 8192
            if flags & 1024 == 1024
              matrix = SwfRuby::Swf::Matrix.new(@data[offset..-1])
              offset += matrix.length
            end
            if flags & 2048 == 2048
              cxtfm = SwfRuby::Swf::Cxformwithalpha.new(@data[offset..-1])
              offset += cxtfm.length
            end
            offset += 2 if flags & 4096 == 4096
            @refer_character_inst_name = SwfRuby::Swf::SwfString.new(@data[offset..-1]).string
          end
        when "RemoveObject"
          @refer_character_id_offset = data_offset
          @refer_character_id = @data[0, 2].unpack("v").first
        else 
          # do nothing.
        end
        @rawdata = swf[0, @length]
        self
      end

      def rawdata_with_define_character_id(character_id)
        if self.define_tag?
          offset = @long_header ? 6 : 2
          @rawdata[offset, 2] = [character_id].pack("v")
        end
        @rawdata
      end

      def rawdata_with_refer_character_id(character_id)
        @rawdata[@refer_character_id_offset, 2] = [character_id].pack("v") if @refer_character_id_offset
        @rawdata
      end

      def define_tag?
        Swf::TAG_TYPE[@code] =~ /^Define/
      end

    end

    class TagError < StandardError; end

    TAG_TYPE = {
      0=>"End",
      1=>"ShowFrame",
      2=>"DefineShape",
      3=>"FreeCharacter",
      4=>"PlaceObject",
      5=>"RemoveObject",
      6=>"DefineBitsJPEG",
      7=>"DefineButton",
      8=>"JPEGTables",
      9=>"SetBackgroundColor",
      10=>"DefineFont",
      11=>"DefineText",
      12=>"DoAction",
      13=>"DefineFontInfo",
      14=>"DefineSound",
      15=>"StopSound",
      17=>"DefineButtonSound",
      18=>"SoundStreamHead",
      19=>"SoundStreamBlock",
      20=>"DefineBitsLossless",
      21=>"DefineBitsJPEG2",
      22=>"DefineShape2",
      23=>"DefineButtonCxform",
      24=>"Protect",
      25=>"PathsArePostscript",
      26=>"PlaceObject2",
      28=>"RemoveObject2",
      29=>"SyncFrame",
      31=>"FreeAll",
      32=>"DefineShape3",
      33=>"DefineText2",
      34=>"DefineButton2",
      35=>"DefineBitsJPEG3",
      36=>"DefineBitsLossless2",
      37=>"DefineEditText",
      38=>"DefineVideo",
      39=>"DefineSprite",
      40=>"NameCharacter",
      41=>"ProductInfo",
      42=>"DefineTextFormat",
      43=>"FrameLabel",
      45=>"SoundStreamHead2",
      46=>"DefineMorphShape",
      47=>"GenerateFrame",
      48=>"DefineFont2",
      49=>"GeneratorCommand",
      50=>"DefineCommandObject",
      51=>"CharacterSet",
      52=>"ExternalFont",
      56=>"Export",
      57=>"Import",
      58=>"ProtectDebug",
      59=>"DoInitAction",
      60=>"DefineVideoStream",
      61=>"VideoFrame",
      62=>"DefineFontInfo2",
      63=>"DebugID",
      64=>"ProtectDebug2",
      65=>"ScriptLimits",
      66=>"SetTabIndex",
      69=>"FileAttributes",
      70=>"PlaceObject3",
      71=>"Import2",
      72=>"DoABC",
      73=>"DefineFontAlignZones",
      74=>"CSMTextSettings",
      75=>"DefineFont3",
      76=>"SymbolClass",
      77=>"Metadata",
      78=>"DefineScalingGrid",
      82=>"DoABCDefine",
      83=>"DefineShape4",
      84=>"DefineMorphShape2",
      86=>"DefineSceneAndFrameData",
      87=>"DefineBinaryData",
      88=>"DefineFontName",
      90=>"DefineBitsJPEG4"
    }

  end
end

#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 
module SwfRuby
  # Swfに含まれるリソースを置換するクラス.
  class SwfTamperer
    # 対象Swf(バイナリ)のリソースを置換.
    # 置換対象はReplaceTargetオブジェクトの配列で渡す.
    def replace(swf, replace_targets)
      replace_targets.sort_by { |a| a.offset }.reverse.each do |rt|
        case rt
        when Jpeg2ReplaceTarget
          swf = repl_jpeg2(swf, rt.offset, rt.jpeg)
        when Lossless2ReplaceTarget
          swf = repl_lossless2(swf, rt.offset, rt.image)
        when AsVarReplaceTarget
          swf = repl_action_push_string(swf, rt.do_action_offset, rt.offset, rt.str, rt.parent_sprite_offset)
        when SpriteReplaceTarget
          swf = repl_sprite(swf, rt.offset, rt.target_define_tags_string, rt.frame_count, rt.target_control_tags_string)
        end
      end
      swf
    end

    private

    # 対象オフセット位置にあるDefineSpriteを指定したControlTags文字列で置換.
    # 新しいSprite含むDefineTagsは、DefineSpriteの直前に挿入する.
    def repl_sprite(swf, offset, define_tags, frame_count, control_tags)
      swf.force_encoding("ASCII-8BIT") if swf.respond_to? :force_encoding
      define_tags.force_encoding("ASCII-8BIT") if define_tags.respond_to? :force_encoding
      control_tags.force_encoding("ASCII-8BIT") if control_tags.respond_to? :force_encoding
      record_header = swf[offset, 2].unpack("v").first
      # tag check
      raise ReplaceTargetError if (record_header >> 6) & 1023 != 39
      # error for short header (not implemented yet.)
      raise ReplaceTargetError if record_header & 63 < 63
      # rewrite frame count
      swf[offset+8, 2] = [frame_count].pack("v")
      # rewrite control tag and length
      sprite_len = swf[offset+2, 4].unpack("i").first # without recordheader
      old_control_tags_len = sprite_len - 4
      delta_control_tags_len = control_tags.length - old_control_tags_len
      swf[offset+10, old_control_tags_len] = control_tags
      swf[offset+2, 4] = [sprite_len + delta_control_tags_len].pack("V")
      # insert define tags before define sprite
      swf[offset, 0] = define_tags
      # rewrite swf header
      swf[4, 4] = [swf[4, 4].unpack("V").first + define_tags.length + delta_control_tags_len].pack("V")
      swf
    end

    # 対象オフセット位置にあるActionPushデータを置換.
    def repl_action_push_string(swf, do_action_offset, action_push_offset, str, parent_sprite_offset = nil)
      swf.force_encoding("ASCII-8BIT") if swf.respond_to? :force_encoding
      str.force_encoding("ASCII-8BIT") if str.respond_to? :force_encoding
      record_header = swf[do_action_offset, 2].unpack("v").first
      # tag check
      raise ReplaceTargetError if (record_header >> 6) & 1023 != 12
      # action check
      raise ReplaceTargetError if swf[action_push_offset].chr.unpack("C").first != 0x96
      raise ReplaceTargetError if swf[action_push_offset + 3].chr.unpack("C").first != 0
      # error for short header (not implemented yet.)
      raise ReplaceTargetError if record_header & 63 < 63
      # calc length
      do_action_len = swf[do_action_offset+2, 4].unpack("i").first # without recordheader
      action_push_len = swf[action_push_offset+1, 2].unpack("v").first
      org_str_length = action_push_len - 2 # data type & terminated null
      delta_str_length = str.length - org_str_length
      # replace string and rewrite length
      swf[action_push_offset+4, org_str_length] = str
      swf[action_push_offset+1, 2] = [action_push_len + delta_str_length].pack("v")
      swf[do_action_offset+2, 4] = [do_action_len + delta_str_length].pack("V")
      if parent_sprite_offset
        swf[parent_sprite_offset+2, 4] = [swf[parent_sprite_offset+2, 4].unpack("V").first + delta_str_length].pack("V")
      end
      swf[4, 4] = [swf[4, 4].unpack("V").first + delta_str_length].pack("V")
      swf
    end

    # DefineBitsJpeg2のイメージバイナリを置換.
    def repl_jpeg2(swf, offset, jpeg)
      swf.force_encoding("ASCII-8BIT") if swf.respond_to? :force_encoding
      jpeg.force_encoding("ASCII-8BIT") if jpeg.respond_to? :force_encoding
      record_header = swf[offset, 2].unpack("v").first
      # tag check (対象がSWF全体なので、効率の面からTagインスタンスを作らないでチェック)
      raise ReplaceTargetError if (record_header >> 6) & 1023 != 21
      # calc length
      org_jpeg_length = record_header & 63 - 2
      before_long_header = false
      after_long_header = false
      if org_jpeg_length == 61
        before_long_header = true
        org_jpeg_length = swf[offset+2, 4].unpack("i").first - 2
      end
      target_jpeg_length = jpeg.length + 4
      delta_jpeg_length = target_jpeg_length - org_jpeg_length
      after_long_header = true if target_jpeg_length + 2 >= 63
      # replace jpeg and rewrite length
      # タグのヘッダ長さが入れ替え前後で変化する場合があるので場合分けする
      if before_long_header and after_long_header
        swf[offset+8, org_jpeg_length] = [0xff, 0xd9, 0xff, 0xd8].pack("C*") + jpeg
        swf[offset+2, 4] = [target_jpeg_length + 2].pack("i")
        swf[4, 4] = [swf[4, 4].unpack("V").first + delta_jpeg_length].pack("V")
      elsif before_long_header and !after_long_header
        swf[offset+8, org_jpeg_length] = [0xff, 0xd9, 0xff, 0xd8].pack("C*") + jpeg
        swf[offset, 4] = [(((record_header >> 6) & 1023) << 6) + target_jpeg_length + 2].pack("v")
        swf[4, 4] = [swf[4, 4].unpack("V").first + delta_jpeg_length - 4].pack("V")
      elsif !before_long_header and after_long_header
        swf[offset+4, org_jpeg_length] = [0xff, 0xd9, 0xff, 0xd8].pack("C*") + jpeg
        swf[offset, 2] = [(((record_header >> 6) & 1023) << 6) + 63].pack("v") + [target_jpeg_length + 2].pack("i")
        swf[4, 4] = [swf[4, 4].unpack("V").first + delta_jpeg_length + 4].pack("V")
      elsif !before_long_header and !after_long_header
        swf[offset+4, org_jpeg_length] = [0xff, 0xd9, 0xff, 0xd8].pack("C*") + jpeg
        swf[offset, 2] = [(((record_header >> 6) & 1023) << 6) + target_jpeg_length + 2].pack("v")
        swf[4, 4] = [swf[4, 4].unpack("V").first + delta_jpeg_length].pack("V")
      end
      swf
    end

    # DefineBitsLossless2のイメージバイナリを置換.
    def repl_lossless2(swf, offset, lossless)
      swf.force_encoding("ASCII-8BIT") if swf.respond_to? :force_encoding

      org_format = swf[offset+8, 1].unpack("C").first
      # replace lossless2 data
      if lossless.format == 3
        if org_format == 3
          org_image_length = swf[offset+2, 4].unpack("i").first - 8
          delta_length = lossless.zlib_bitmap_data.size - org_image_length
          swf[offset+14, org_image_length] = lossless.zlib_bitmap_data
          swf[offset+13, 1] = [lossless.color_table_size].pack("C")
          swf[offset+11, 2] = [lossless.height].pack("v")
          swf[offset+9, 2] = [lossless.width].pack("v")
          swf[offset+8, 1] = [lossless.format].pack("C")
          swf[offset+2, 4] = [lossless.zlib_bitmap_data.size + 8].pack("i")
        elsif org_format == 5
          org_image_length = swf[offset+2, 4].unpack("i").first - 7
          delta_length = lossless.zlib_bitmap_data.size - org_image_length + 1
          swf[offset+13, org_image_length] = [lossless.color_table_size].pack("C") + lossless.zlib_bitmap_data
          swf[offset+11, 2] = [lossless.height].pack("v")
          swf[offset+9, 2] = [lossless.width].pack("v")
          swf[offset+8, 1] = [lossless.format].pack("C")
          swf[offset+2, 4] = [lossless.zlib_bitmap_data.size + 8].pack("i")
        else
          raise ReplaceTargetError
        end
      elsif lossless.format == 5
        if org_format == 3
          org_image_length = swf[offset+2, 4].unpack("i").first - 8
          delta_length = lossless.zlib_bitmap_data.size - org_image_length - 1
          swf[offset+13, org_image_length+1] = lossless.zlib_bitmap_data
          swf[offset+11, 2] = [lossless.height].pack("v")
          swf[offset+9, 2] = [lossless.width].pack("v")
          swf[offset+8, 1] = [lossless.format].pack("C")
          swf[offset+2, 4] = [lossless.zlib_bitmap_data.size + 7].pack("i")
        elsif org_format == 5
          org_image_length = swf[offset+2, 4].unpack("i").first - 7
          delta_length = lossless.zlib_bitmap_data.size - org_image_length
          swf[offset+13, org_image_length] = lossless.zlib_bitmap_data
          swf[offset+11, 2] = [lossless.height].pack("v")
          swf[offset+9, 2] = [lossless.width].pack("v")
          swf[offset+8, 1] = [lossless.format].pack("C")
          swf[offset+2, 4] = [lossless.zlib_bitmap_data.size + 7].pack("i")
        else
          raise ReplaceTargetError
        end
      else
        raise ReplaceTargetError
      end
      swf[4, 4] = [swf[4, 4].unpack("V").first + delta_length].pack("V")
      swf
    end
  end

end

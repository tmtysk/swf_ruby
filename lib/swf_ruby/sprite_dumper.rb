#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  # DefineSpriteをダンプするクラス.
  class SpriteDumper
    attr_reader :sprite_id
    attr_reader :frame_count
    attr_reader :tags
    attr_reader :tags_addresses

    # 初期化.
    def initialize
      @sprite_id = nil
      @frame_count = nil
      @tag = nil
      @tags_addresses = nil
    end

    # ダンプして構造をインスタンス変数に格納.
    def dump(tag)
      data = tag.data
      @sprite_id = data[0, 2].unpack("v").first
      @frame_count = data[2, 2].unpack("v").first
      @tags = []
      @tags_addresses = []
      sprite_header_length = (tag.long_header) ? 6 : 2
      tag_index = 4
      while tag_index < data.length
        @tags_addresses << tag_index + sprite_header_length
        tag = Swf::Tag.new(data[tag_index..-1])
        tag_index += tag.length
        @tags << tag
      end
      self
    end
  end
end

#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  # Swf構造をダンプするクラス.
  class SwfDumper
    attr_reader :swf
    attr_reader :header
    attr_reader :tags
    attr_reader :tags_addresses

    # 初期化.
    def initialize
      @swf = nil
      @header = nil
      @tags = nil
      @tags_addresses = nil
    end

    # ファイルをバイナリモードで読み込み.
    # 1.9環境の場合はエンコーディング指定.
    def open(file)
      f = File.open(file, "rb").read
      f.force_encoding("ASCII-8BIT") if f.respond_to? :force_encoding
      dump(f)
    end

    # ダンプして構造をインスタンス変数に格納.
    def dump(swf)
      @swf = swf
      @header = Swf::Header.new(@swf)
      @tags = []
      @tags_addresses = []
      tags_length = 0
      while @header.length + tags_length < @header.file_length
        addr = @header.length + tags_length
        @tags_addresses << addr
        tag = Swf::Tag.new(@swf[addr..-1])
        tags_length += tag.length
        @tags << tag
      end
      self
    end

  end
end

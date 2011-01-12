#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  class DoActionDumper

    attr_accessor :tag
    attr_accessor :actions
    attr_accessor :actions_addresses

    def initialize
      @actions = nil
      @actions_addresses = nil
    end

    def dump(tag)
      @tag = tag
      @tag = @tag.force_encoding("ASCII-8BIT") if @tag.respond_to? :force_encoding
      record_header = @tag[0, 2].unpack("v").first
      t = Swf::Tag.new(@tag)
      # tag check
      raise NotDoActionTagError if t.code != 12
      # length check
      raise InvalidTagLengthError if t.length != @tag.length

      @actions = []
      @actions_addresses = []
      tags_index = (t.long_header) ? 6 : 2
      while tags_index < t.length
        @actions_addresses << tags_index
        ar = Swf::ActionRecord.new(@tag[tags_index..-1])
        tags_index += ar.length
        @actions << ar
      end
    end
  end

  class NotDoActionTagError < StandardError; end
  class InvalidTagLengthError < StandardError; end
end

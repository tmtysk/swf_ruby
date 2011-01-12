#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    # ActionPushタグ.
    class ActionPush
      attr_reader :data_type
      attr_reader :data

      def initialize(action_record)
        raise NotActionPushError if action_record.code != 0x96
        ad = action_record.data
        @data_type = ad[0].chr.unpack("C").first
        @data = nil
        d = ad[1..-1]
        case @data_type
        when 0
          @data = d
        when 1
          @data = d.unpack("e")
        when 4,5,8
          @data = d.unpack("C")
        when 6
          @data = d.unpack("E")
        when 7
          @data = d.unpack("V")
        when 9
          @data = d.unpack("v")
        end
      end
    end

    class NotActionPushError < StandardError; end
  end
end

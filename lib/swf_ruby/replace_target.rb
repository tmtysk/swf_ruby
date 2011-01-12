#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  class ReplaceTarget
    attr_accessor :offset
  end

  class Jpeg2ReplaceTarget < ReplaceTarget
    attr_accessor :jpeg

    def initialize(offset, jpeg)
      @offset = offset
      @jpeg = jpeg
    end
  end

  class AsVarReplaceTarget < ReplaceTarget
    attr_accessor :do_action_offset
    attr_accessor :str
    attr_accessor :parent_sprite_offsets

    def initialize(action_push_offset, do_action_offset, str, parent_sprite_offsets = [])
      @offset = action_push_offset
      @do_action_offset = do_action_offset
      @str = str
      @parent_sprite_offsets = parent_sprite_offsets
    end
  end
end

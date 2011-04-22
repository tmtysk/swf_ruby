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

  class Lossless2ReplaceTarget < ReplaceTarget
    attr_accessor :image

    def initialize(offset, image)
      @offset = offset
      @image = SwfRuby::Swf::BitsLossless2.new(image)
    end
  end

  class AsVarReplaceTarget < ReplaceTarget
    attr_accessor :do_action_offset
    attr_accessor :str
    attr_accessor :parent_sprite_offset

    def initialize(action_push_offset, do_action_offset, str, parent_sprite_offset = nil)
      @offset = action_push_offset
      @do_action_offset = do_action_offset
      @str = str
      @parent_sprite_offset = parent_sprite_offset
    end

    # 指定したAS変数名に対するAsVarReplaceTargetのリストを生成する
    def self.build_by_var_name(swf_dumper, var_name)
      as_var_replace_targets = []
      swf_dumper.tags.each_with_index do |t, i|
        if t.code == 39
          # DefineSprite
          sd = SwfRuby::SpriteDumper.new
          sd.dump(t)
          sd.tags.each_with_index do |u, j|
            if u.code == 12
              # DoAction in DefineSprite
              as_var_replace_targets += AsVarReplaceTarget.generate_as_var_replace_target_by_do_action(var_name, swf_dumper, j, sd, swf_dumper.tags_addresses[i])
            end
          end
        end
        if t.code == 12
          # DoAction
          as_var_replace_targets += AsVarReplaceTarget.generate_as_var_replace_target_by_do_action(var_name, swf_dumper, i)
        end
      end
      as_var_replace_targets
    end

    # 指定したインデックス(SWFまたはSpriteの先頭からカウント)にあるDoAction以下を走査し、
    # 指定したAS変数名の代入部分を発見し、AsVarReplaceTargetのリストを生成する.
    def self.generate_as_var_replace_target_by_do_action(var_name, swf_dumper, do_action_index, sprite_dumper = nil, parent_sprite_offset = nil)
      as_var_replace_targets = []
      action_records = []
      do_action_offset = 0

      dad = SwfRuby::DoActionDumper.new
      if sprite_dumper
        do_action_offset = parent_sprite_offset + sprite_dumper.tags_addresses[do_action_index]
        dad.dump(swf_dumper.swf[do_action_offset, sprite_dumper.tags[do_action_index].length])
      else 
        do_action_offset = swf_dumper.tags_addresses[do_action_index]
        dad.dump(swf_dumper.swf[do_action_offset, swf_dumper.tags[do_action_index].length])
      end
      dad.actions.each_with_index do |ar, i|
        # ActionPush, ActionPush, SetVariableの並びを検出したら変数名をチェック.
        action_records.shift if action_records.length > 2
        action_records << ar
        if ar.code == 29 and
          action_records[0] and
          action_records[0].code == 150 and
          action_records[0].data.delete("\0") == var_name and
          action_records[1].code == 150
          # 対象の代入式を発見.
          ap = SwfRuby::Swf::ActionPush.new(action_records[1])
          as_var_replace_targets << AsVarReplaceTarget.new(
            do_action_offset + dad.actions_addresses[i] - action_records[1].length,
            do_action_offset,
            "",
            parent_sprite_offset
          )
        end
      end
      as_var_replace_targets
    end
  end

end

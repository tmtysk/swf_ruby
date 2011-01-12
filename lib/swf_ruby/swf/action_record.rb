#  vim: set fileencoding=utf-8 filetype=ruby ts=2 : 

module SwfRuby
  module Swf
    class ActionRecord
      attr_reader :code
      attr_reader :length
      attr_reader :data

      def initialize(tag)
        tag.force_encoding("ASCII-8BIT") if tag.respond_to? :force_encoding
        # action code
        @code = tag[0].chr.unpack("C").first
        # length (including action record header) and data
        @length = 1
        @data = nil
        if @code >= 0x80
          len = tag[1,2].unpack("v").first
          @length += len + 2
          @data = tag[3,len]
        end
      end
    end

    ACTION_RECORDS = {
      71=>"Add (typed)",
      10=>"Add",
      96=>"And",
      153=>"Branch Always",
      157=>"Branch If True",
      158=>"Call Frame",
      61=>"Call Function",
      82=>"Call Method",
      43=>"Cast Object",
      55=>"Chr (multi-byte)",
      51=>"Chr",
      33=>"Concatenate Strings",
      66=>"Declare Array",
      136=>"Declare Dictionary",
      142=>"Declare Function (V7)",
      155=>"Declare Function",
      65=>"Declare Local Variable",
      67=>"Declare Object",
      81=>"Decrement",
      58=>"Delete",
      59=>"Delete All",
      13=>"Divide",
      76=>"Duplicate",
      36=>"Duplicate Sprite",
      0=>"End (action)",
      70=>"Enumerate",
      85=>"Enumerate Object",
      73=>"Equal (typed)",
      14=>"Equal",
      105=>"Extends",
      45=>"FSCommand2",
      78=>"Get Member",
      34=>"Get Property",
      69=>"Get Target",
      52=>"Get Timer",
      131=>"Get URL",
      154=>"Get URL2",
      28=>"Get Variable",
      159=>"Goto Expression",
      129=>"Goto Frame",
      140=>"Goto Label",
      103=>"Greater Than (typed)",
      44=>"Implements",
      80=>"Increment",
      84=>"Instance Of",
      24=>"Integral Part",
      72=>"Less Than (typed)",
      15=>"Less Than",
      16=>"Logical And",
      18=>"Logical Not",
      17=>"Logical Or",
      63=>"Modulo",
      12=>"Multiply",
      64=>"New",
      83=>"New Method",
      4=>"Next Frame",
      74=>"Number",
      97=>"Or",
      54=>"Ord (multi-byte)",
      50=>"Ord",
      6=>"Play",
      23=>"Pop",
      5=>"Previous Frame",
      150=>"Push Data",
      48=>"Random",
      37=>"Remove Sprite",
      62=>"Return",
      60=>"Set Local Variable",
      79=>"Set Member",
      35=>"Set Property",
      32=>"Set Target (dynamic)",
      139=>"Set Target",
      29=>"Set Variable",
      99=>"Shift Left",
      100=>"Shift Right",
      101=>"Shift Right Unsigned",
      39=>"Start Drag",
      7=>"Stop",
      40=>"Stop Drag",
      9=>"Stop Sound",
      135=>"Store Register",
      102=>"Strict Equal",
      137=>"Strict Mode",
      75=>"String",
      19=>"String Equal",
      104=>"String Greater Than",
      49=>"String Length (multi-byte)",
      20=>"String Length",
      41=>"String Less Than",
      53=>"SubString (multi-byte)",
      21=>"SubString",
      11=>"Subtract",
      77=>"Swap",
      42=>"Throw",
      8=>"Toggle Quality",
      38=>"Trace",
      143=>"Try",
      68=>"Type Of",
      141=>"Wait For Frame (dynamic)",
      138=>"Wait For Frame",
      148=>"With",
      98=>"XOr"
    }

  end
end

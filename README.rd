= SwfRuby

SwfRuby is a utilities to dump or manipulate SWF with Ruby.

* features
 * SwfRuby::SwfDumper
  * Analysing the structure of specified SWF.
  * Used from 'swf_dump' command.
 * SwfRuby::SwfTamperer
  * Manipulating(replagcing) resources in SWF.
  * Used from 'swf_jpeg_replace' command.
 * compatible on ruby-1.8.7 and ruby-1.9.2.

= Dependencies

* bundler (>= 1.0.0.rc.5)

= Installation

 $ git clone http://github.com/tmtysk/swf_ruby
 $ cd swf_ruby
 $ bundle install
 $ rake install

= Command Usage

== Analysing the structure of SWF

 $ swf_dump samples/sample.swf
 SetBackgroundColor, offset: 20, length: 5
 DefineFont2, offset: 25, length: 34
 DefineEditText, offset: 59, length: 50
 PlaceObject2, offset: 109, length: 11
 DefineBitsLossless2, offset: 120, length: 178
 DefineShape, offset: 298, length: 55
 :

== Replacing Jpeg in SWF

 $ swf_jpeg_replace samples/sample.swf 623 samples/bg.jpg > samples/sample2.swf
 # <623> is offset to Jpeg resource getting by swf_dump.

= Thanks

* Sample GIF image is provided by ICHIGO-APORO.

Copyright (c) 2011 tmtysk.
released under the GNU GENERAL PUBLIC LICENSE Version 2.
See COPYING for details.

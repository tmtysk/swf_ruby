SwfRuby
=======

SwfRuby is a utilities to dump or manipulate a SWF with Ruby.

* features
  * SwfRuby::SwfDumper
    * Analysing the structure of specified SWF.
    * Used from 'swf_dump' command.
  * SwfRuby::SwfTamperer
    * Manipulating(replagcing) resources in SWF.
    * Used from 'swf_jpeg_replace' command.
  * compatible on ruby-1.8.7 and ruby-1.9.2.

Dependencies
============

* RMagick >= 2.13.0 (ImageMagick >= 6.5.7)

Installation
============

    $ gem install swf_ruby

    or

    $ git clone git://github.com/tmtysk/swf_ruby.git
    $ cd swf_ruby
    $ rake install

Command-Line Tool Usage
=======================

Analysing the structure of SWF
------------------------------

    $ swf_dump samples/sample.swf
    SetBackgroundColor, offset: 20, length: 5
    DefineFont2, offset: 25, length: 34
    DefineEditText, offset: 59, length: 50
    PlaceObject2, offset: 109, length: 11
    DefineBitsLossless2, offset: 120, length: 178
    DefineShape, offset: 298, length: 55
    :
    DefineBitsJPEG2, offset: 623, length: 10986
    :

Replacing Jpeg in SWF
---------------------

    $ swf_jpeg_replace samples/sample.swf 623 samples/bg.jpg > samples/sample2.swf
    # <623> is offset to DefineBitsJPEG2 resource getting by 'swf_dump'.

Thanks
======

* Sample GIF image is provided by ICHIGO-APORO.

Copyright (c) 2011 tmtysk.
released under the GNU GENERAL PUBLIC LICENSE Version 2.
See COPYING for details.

# The tests of tst/run.sh.

shots layout   layout.slides   960 540  8 4:dn:Right,6:dn:Right             2 5 7
shots text     text.slides     960 540  8 4:dn:Right,6:dn:Right             2 5 7
shots image    image.slides    960 540  8 4:dn:Right,6:dn:Right             2 5 7
shots list     list.slides     960 540  8 4:dn:Right,6:dn:Right             2 5 7
shots sections sections.slides 960 540 12 3:dn:Right,5:dn:End,7:dn:Left,9:dn:Home,10:dn:Left  2 4 6 8 11
shots aspect   aspect.slides   800 400  3 -                                 2
shots stretch  stretch.slides  800 400  3 -                                 2
shots names    names.slides    960 540  6 3:dn:Right                        2 5
shots builtin  builtin.slides  640 360  3 -                                 2
shots square   layout.slides   500 500  3 -                                 2

# the examples
shots tour     ../exs/tour/tour.slides 960 540 15 3:dn:Right,5:dn:Right,7:dn:Right,9:dn:Right,11:dn:Right,13:dn:Right  2 4 6 8 10 12 14
shots program  ../exs/program/main.atm - - 6 3:dn:Right                     2 5

refuse overflow-height  "slides : slide 1 > 0:Row > 1:Col > 0:text : text does not fit : height exceeds by"
refuse overflow-width   "slides : slide 1 > 0:Row > 6:text : text does not fit : width exceeds by"
refuse overflow-list    "slides : slide 1 > 2:List : text does not fit : height exceeds by"
refuse overflow-second  "slides : slide 2 > 0:text : text does not fit"
refuse unknown-field    "slides : slide 1 > 0:text : unknown field : colour"
refuse unknown-block    "slides : slide 1 > 0:Grid : unknown block : :Grid"
refuse unknown-group    "slides : slide 1 > 0:text : invalid color : unknown field : front"
refuse bad-color        "slides : slide 1 > 0:text : invalid color.fg : expected color"
refuse bad-anchor       "slides : slide 1 : invalid anchor"
refuse bad-rect         "slides : slide 1 > 0:text : invalid rect : expected both x and y, or none"
refuse bad-rect-mode    "slides : slide 1 > 0:text : invalid rect : expected ['%', ...]"
refuse bad-span         "slides : slide 1 > 0:text : invalid span"
refuse bad-aspect       "slides : :Slides : invalid aspect : expected [w, h]"
refuse bad-fit          "slides : :Slides : invalid fit"
refuse slide-in-block   "slides : slide 1 > 0:Row > 0:Slide : unknown block : :Slide"
refuse block-in-slides  "slides : :Slides > 0 : expected :Slide or :Section"
refuse block-in-section "slides : :Slides > 0:Section > 0 : expected :Slide"
refuse section-no-title "slides : :Slides > 0:Section : invalid title : expected string"
refuse kids-in-leaf     "slides : slide 1 > 0:text : expected a single string"
refuse no-image         "slides : slide 1 > 0:image : file not found : nothing.png"
refuse no-font          "slides : :Slides : invalid font.file : file not found : nothing.ttf"
refuse not-slides       "slides : document : expected :Slides [...]"
refuse list-image       "slides : slide 1 > 0:List > 1:image : a :image in a :List needs a height (rect.h)"
refuse undefined-name   "invalid load : line 1 : undefined name : LOGO"

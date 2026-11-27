# TODO

The state of `pico-slides`: what waits for the author, what is known and
not done. Items are `#N`, in the order they were put to him, never
reused. The decisions themselves are in `doc/design.md`.

Rule of the author (2026-11-20): always write in `main`, in small
commits, with a pull with rebase before each push.

Rule of the author (2026-11-26, for every project with a screen, relayed
by `atmos`): at each big step (a milestone, a feature that changes what
is on screen), show him a few screenshots in the report.

Rule of the author (2026-11-26, for every project, relayed by `atmos`):
for each group of changes, show one pair of short Atmos excerpts from
that work, with file and line: one idiomatic, one bad (awkward,
verbose, a workaround). Each excerpt takes a number of this
session's sequence, and each bad one says why it is bad and what would
make it better (the language, the environment, or the port) (2026-11-26).

Rule of the author (2026-11-26, relayed by `atmos`): read
`ia-atmos/lang` `.claude/plans/IDIOMS.md` before writing Atmos. When
he corrects or approves an excerpt and a general rule comes out of it,
send it to `atmos`, with its `pico-slides#N` and a before and an after.

## Waits for the author

Each item has a number, a description, and the session's
recommendation. Listed on 2026-11-25.

| Item | Description | Recommended |
|---|---|---|
| #48 | Where `aspect` and `fit` go: the document or the command line | done: `aspect` in the document; `./slides --fit=stretch|bars`, the `=` mandatory |
| #11 | `:Contents []` as a block of the format | #11b (2026-11-26): removed; only the automatic `toc` |
| #49 | The marker of a list item takes the color of the item's text | settled with #72 |
| #50 | Convert the slides of the courses, starting with LP1 | pilot done by hand (#62a): `exs/lp1/lp1-02-c.slides`, 9 slides. Missing for a faithful copy: boxes that fit their code (#64), the balloon of slide 8 (#57), the gradient of the background |
| #51 | `:Box`: a frame around its content | done: `:Box [ border=[size=, color=], <one block> ]` |
| #52 | A container with a single element needs no `:Row` or `:Col` | done: a `:Box` with no `border` |
| #53 | Formatted text: `**bold**`, `*italic*`, `` `code` `` inside a text | done (#53a, #66d): `:text.rich`, fonts in `font=[bold=, italic=, mono=]`; the LP1 pilot has its keywords in bold |
| #54 | `anim=true` would hide the first child too, with a per-child way to show it from the start | decide together with #55, which gives that per-child field |
| #55 | `step` back, as a field of a child: `step=false` shows it with its parent; a step local (in the parent's sequence) or global (of the slide) | `step=false` and a local `step=N` first; global steps when overlays (#57) need them |
| #56 | A `:Section` starts with its table of contents, unless `toc=false` | done with #11b: on by default (the author's idea), `toc=false` in a `:Section` or in `:Slides`. The look of the slide (no title, centered) was chosen by the session |
| #57 | Overlays: arrows, rectangles, and texts over the objects of a slide, which needs an id for an object | a field `id` on any block, and overlay blocks that point at ids; after #55, since an overlay usually comes at a step |
| #58 | Send the vocabulary to `paper-media` | approved by the author on 2026-11-25; see the log below |
| #59 | The readme: what it says of Aurora and of Thiago Presotto, and whether he is told | review the paragraph; telling him is the author's |
| #60 | A key that shows the table of contents at any time (the `T` of Aurora) | open; it would show the same generated slide |
| #61 | References (the `Ref` table and `Reference` slide of Aurora) | later; when needed, a block made from a table of references, as `:Contents` is made from the sections |
| #62 | How to convert LP1: by hand or with a converter of `.fodp` | #62a, by hand, the class of C as a pilot |
| #63 | Formatted text (#53): in pico or in the engine | the engine, over pico as it is (fonts by file for bold and italic); confirmed 2026-11-25 |
| #64 | A `:Box` with a border fills the rectangle it receives; in LP1 each box fits its code | to discuss: a box that takes the size of its content |
| #65 | Automatic line breaking (#12a) | #65b: off by default, `wrap=true` (inherited) turns it on; with no wrap, lines and blanks are as written; done |
| #66 | The tag of formatted text | #66d: `:text.rich`, a subtype of `:text` |
| #67 | One font for bold and italic | #67a: pico synthesizes them (env-pico#18, 662a659); `font.bold` and `font.italic` are optional; done |
| #68 | Steps as tasks, or computed at load | computed at load, the main loop of Aurora; it stays (2026-11-25) |
| #69 | A presentation may fail on a smaller window (overflow is an error, no aspect, no wrap) | open: recommended to always give `aspect`, and to check with `--pdf` |
| #70 | Use the anchors and relative rects of pico in the engine | superseded by #71 |
| #71 | The engine in relative coordinates | done: the layout measures at the size of the world when it is made, and draws in `'%'` with the anchors of pico; with a fixed `aspect`, a resize needs no new layout. Layers per frame (#70b) later, when steps by visibility, effects, or overlays ask for them |
| #72 | The marker of a `:List` | #72a: `mark=:dot|:none|:num|:alpha|"string"`, inherited by sublists; done |
| #73 | Excerpt, idiomatic: `Slides.mark_label`, `src/slides.atm:950`, an `ifs` as an expression | shown 2026-11-26 |
| #74 | Excerpt, bad (fixed in #76): the width of the markers, `src/slides.atm:963` then, a second pass over the items with a hand counter, measured through `Slides.wrap` | shown 2026-11-26; the fault is of the port (a measuring function, labels in a vector); `iter.filter` and `iter.max` of the language would shorten it |
| #75 | The answer to the general instruction for the ports (freedom, idioms, files, bugs) | given 2026-11-26: grade 6 of 10; the idioms of the engine are the weak point |
| #76 | Redo the engine with the idioms of #75 (b) | done 2026-11-26: the check as tables; no global state (a context for the layout, a view for the tasks that draw); marks with `iter`; the table of contents with no hidden tag; `await false`. Not done: the type tests stay `type(v) == 'table'` (#82); the parser of `:text.rich` still walks by index |
| #77 | Excerpt, idiomatic: the default of `toc`, `Slides.flat`, an `if` as an expression over an optional field | shown 2026-11-26 |
| #78 | Excerpt, bad (fixed in #76): the generated slide is a node `:Slide [ :Contents [...] ]` with a tag that the check refuses | shown 2026-11-26; the fault is of the port: generated content should be laid out directly, not through a hidden tag |
| #79 | Excerpt, idiomatic: `kinds@k`, `src/slides.atm:90`, a table as the description of a group of fields, indexed by the key in hand | shown 2026-11-26, with the rewrite of `@(name)` to `@name` (3 places, asked for all projects) |
| #80 | Excerpt, bad (the key fixed in #76; the search stays): the cache of point sizes, `src/slides.atm:512`, a string key built by hand and a search by trial | shown 2026-11-26; the search is a workaround for pico (a text with an exact line height, env-pico#14); the key is of the port (a table per font would do) |
| #81 | Excerpt, idiomatic: `Slides.fields` and `Slides.check_fields`, `src/slides.atm:178` and `:219`, the fields of each tag as data | shown 2026-11-26 |
| #82 | Excerpt, bad: `Slides.istab`, `src/slides.atm:46`, a type test by hand because `??` is not safe on a string of the document (`"table" ?? :table` is true) | answered 2026-11-26 (a), as atmos-lang advised: a tag test on a value that may be a string is `v ?? :T []` (a table pattern), with no `Slides.istab` before it; done in the check, `Slides.text_block`, and the marks. Of the language: `??` mixes equality, type, and tag prefix |
| #83 | Excerpt, idiomatic: `src/slides.atm:294`, `s ?? :Slide [] => ...`, a tag test that a string of the document cannot pass | shown 2026-11-26 |
| #84 | Excerpt, bad: `src/slides.atm:943`, `ktag ?? :text` where `ktag` is a tag or `:text` for a string; works, but the tag is taken out of the node only to be tested | shown 2026-11-26; of the port. Fixed 2026-11-27 (#85 a): `Slides.isstr(k) || (k ?? :text [])`, and `sub = k ?? :List []` for a list inside the list |
| #85 | Fix #84? | answered 2026-11-27: (a) yes |
| #86 | Excerpt, idiomatic: `val sub = k ?? :List []`, the node tested, not its tag | shown 2026-11-27; replaced by #89 |
| #87 | Excerpt, bad: `Slides.isstr(k) \|\| (k ?? :text [])`, "is a text" said twice | shown 2026-11-27; of the port |
| #88 | A `Slides.istext`? | replaced by #89 |
| #89 | One `Slides.is(v, T)` for every test of type or tag (a string is a :text and no other tag); no `:X []`, no `isstr`/`istab`/`isnum` | answered 2026-11-27: (a), and tell atmos-lang; done. atmos-lang: `v ?? T []` with a tag in a variable is a call, not a pattern; `v ?? [tag=T]` works; `Slides.is` keeps `v ?? T` after the type test |

The table form of `anim` (#6: something that disappears, shows only at
some keys, or is highlighted) waits for #54 and #55.

## Index of items

| Item | Subject | State |
|---|---|---|
| #1 | The form of a node | #1a, a uniform tree |
| #2 | How a node gets its rectangle | #2a, from the parent, with a `rect` |
| #3 | The leaves, `List` and `Table` | #3a, with no `:Table` |
| #4 | Style | #4a, inherited, in `color=[]` and `font=[]`, colors as tags |
| #5 | Sections | #5a, `:Section` |
| #6 | Steps | #6a implemented and removed (#45); `anim=true` instead (#47) |
| #7 | Only data, or functions | answered by `X.loadx`: data with names |
| #8 | Composites of layout | #8a, `:Row` and `:Col`; the slide stacks |
| #9 | Inheritance in a group | #9a, field by field |
| #10 | Alignment | #10a, `anchor`, inherited |
| #11 | The table of contents | #11a, implemented, to be confirmed |
| #12 | The size of a leaf | #12a, an image fits, a text breaks |
| #13 | Unequal parts | #13a, a weight in the child |
| #14 | Spaces | #14a, two fields; `gap` inherited, `pad` not (#29) |
| #15 | The title | #15a, a field with a band |
| #16 | A text that does not fit | an error, always |
| #17 | The dimension of the slide | `aspect`, or the window if absent |
| #18 | The `h` of a text with many lines | #18a, one line |
| #19 | The name of the weight | #19h, `span` |
| #20 | The names of the spaces | #20a, `cell=[pad=, gap=]` |
| #21 | The default of `aspect` | absent follows the window |
| #22 | Stretch or bars | #22a, `fit=:bars` or `:stretch` |
| #23 | Next step (write the design) | done |
| #24 | Next step (the set aside items) | done for #16 |
| #25 | The default of `fit` | #25b, `:stretch`, as pico |
| #26 | Next step | he said to go ahead with all that can be done |
| #27 | A name for a whole style | #27a, nothing for now |
| #29 | The inheritance of `pad` | not inherited, as the engine does |
| #28 | The items of a `:List` | #28a, together; an item that is not a text needs `rect.h` |
| #30-#36 | Choices of the engine (defaults, title, marker, blanks, line, keys) | confirmed as a whole (#37); #33 went with #28 |
| #37 | Confirm the choices of the engine | yes |
| #38 | Next step | #38a, steps |
| #39 | Confirm #6a and #11a | read as yes from an "ok" that most likely answered #40; undone (#45) |
| #40 | Answer `atmos-loadx` and `env-pico` | yes, sent |
| #41 | A PDF | #41a, an image of each slide |
| #42 | A page for a slide or for a step | a slide; `--steps` removed with steps (#45) |
| #43 | Next step | nothing for now |
| #44 | The cache of texts of pico grows at each resize | yes: pico empties it when the dim of a layer changes (env-pico 8a20c464) |
| #45 | Steps: confirm `step=N`, or revert | revert, and discuss in depth |
| #46 | What a step can do | superseded by #47 |
| #47 | `anim=true` in a composite: children one per key, the first from the start, nested in reading order | agreed |

## Known, not done

- The fullscreen is not covered by tests (a resize is, since pico has
  `PICO_ATM_RESIZE`).
- The visual tests still run under `xvfb-run`. Pico now runs with no
  display (`atmos-pico -t`, which the PDF uses), with another renderer:
  to move the tests there, the references must be made again.
- The text of a PDF is not selectable (#41b would give that).
- `./slides` compiles the engine at each run (a few seconds). A build
  that is kept would start at once.
- Memory over many resizes (measured 2026-11-22, `tst/text.slides`,
  90 resizes): with no display (`atmos-pico -t`), it stays bounded,
  26 MB at the start and 45 MB at the end. Under `xvfb-run` it grows
  about 3 MB per resize, also with the cache emptied, and the same
  growth appears with the old pico: it comes from the graphics driver
  of the test machine (Mesa), not from pico or from the engine.
- No word is broken: a word wider than its rectangle is an error.
- The references of the visual tests depend on the versions of SDL and
  FreeType.
- `Slides.check` does not check the type of every field in depth (a
  color is checked with pico, a font and an image by opening the file).

## Other sessions

| Session | Subject | State |
|---|---|---|
| `atmos-loadx` (`ia-atmos/lang`) | `X.loadx`, data with names | done, in `main`; used by `src/main.atm` |
| `env-pico` | `fit` in the scene of a layer | done, in `main`; used by `Slides.world` |
| `env-pico` | what the engine works around: line breaking (env-pico#13), exact line height (#14), the cache of texts (#15), scripted resize (done) | #12 confirmed; #13, #14 kept as todo there; #15: done in env-pico 8a20c464 (#44): the cache of texts is emptied when the dim of a layer changes |
| `paper-media` (`ia-atmos/lang`) | asked for the vocabulary when agreed (tags, fields, how time would enter) | not sent: the message was refused by the permissions of this session, and waits for the author to ask for it |

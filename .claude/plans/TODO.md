# TODO

The state of `pico-slides`: what waits for the author, what is known and
not done. Items are `#N`, in the order they were put to him, never
reused. The decisions themselves are in `doc/design.md`.

## Waits for the author

Each has a recommended option. The first block is what the engine
already does, with no answer from him.

| Item | Question | Recommended, and what the engine does |
|---|---|---|
| #28 | How the items of a `:List` take the height | #28a: each item with the height of its content; the engine does this |
| #30 | The default values | size `0.05`, pad `0.04`, gap `0.02`, black on white, window `960x540` |
| #31 | The style of a title | 1.5 times the text, centered at the top |
| #32 | The marker of a `:List` | a drawn dot, no field |
| #33 | An `:image`, `:Row`, or `:Col` as an item of a `:List` | needs `rect.h`, relative to the list |
| #34 | Blanks in a text | collapse between words, kept at the start of a line |
| #35 | The height of a line | the size of the font is the whole line, leading included |
| #36 | The keys | as in the readme |

Not implemented, and open:

| Item | Question | Recommended |
|---|---|---|
| #6 | Steps inside a slide | #6a: a field `step=N` in any block |
| #11 | The table of contents in the source | #11a: a block `:Contents []` |
| - | References (the `Ref` and `Reference` of Aurora) | not discussed |
| - | A style for all titles at once | not discussed since `X.loadx` has no spread |
| - | The readme: what it says of Aurora and of Presotto, and whether he is told | written in a neutral way, to be reviewed |
| - | The branch: the work is in `ccr-a4a702e3-dtgv66`, not in `main` | to be merged when he says |

## Index of items

| Item | Subject | State |
|---|---|---|
| #1 | The form of a node | #1a, a uniform tree |
| #2 | How a node gets its rectangle | #2a, from the parent, with a `rect` |
| #3 | The leaves, `List` and `Table` | #3a, with no `:Table` |
| #4 | Style | #4a, inherited, in `color=[]` and `font=[]`, colors as tags |
| #5 | Sections | #5a, `:Section` |
| #6 | Steps | set aside |
| #7 | Only data, or functions | answered by `X.loadx`: data with names |
| #8 | Composites of layout | #8a, `:Row` and `:Col`; the slide stacks |
| #9 | Inheritance in a group | #9a, field by field |
| #10 | Alignment | #10a, `anchor`, inherited |
| #11 | The table of contents | set aside |
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
| #28, #30-#36 | Choices of the engine | wait for him (above) |

## Known, not done

- A resize of the window and the fullscreen are not covered by tests:
  the scripted events of pico have keys and the mouse only.
- `./slides` compiles the engine at each run (a few seconds). A build
  that is kept would start at once.
- The text layers that pico keeps for each string and size are only
  released when pico closes: many resizes of a long presentation grow
  the memory.
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
| `paper-media` (`ia-atmos/lang`) | asked for the vocabulary when agreed (tags, fields, how time would enter) | not sent yet: the author did not ask |

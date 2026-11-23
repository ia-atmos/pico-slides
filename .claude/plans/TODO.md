# TODO

The state of `pico-slides`: what waits for the author, what is known and
not done. Items are `#N`, in the order they were put to him, never
reused. The decisions themselves are in `doc/design.md`.

Rule of the author (2026-11-20): always write in `main`, in small
commits, with a pull with rebase before each push.

## Waits for the author

By the session, to be confirmed (each is reversible):

| Item | What was done | To undo |
|---|---|---|
| #11 | #11a: `:Contents []`, a list of the titles of the sections. Marked as confirmed (#39) from an "ok" that most likely answered #40: back to be confirmed | remove `Slides.lay_contents` and the tag |
| - | The dot of an item of a list has the color of the text of the item | one line in `Slides.lay_list_at` |

Open, with no recommendation acted on:

| Item | Question | Recommended |
|---|---|---|
| - | A key for the table of contents at any time (the `T` of Aurora) | not discussed |
| - | References (the `Ref` and `Reference` of Aurora) | not discussed |
| #6 | Steps inside a slide | open again (#45): the first version (`step=N`) was removed on 2026-11-23, to be discussed in depth (how Beamer, reveal.js, PowerPoint, and Typst do it is in the conversation of that day) |
| - | The readme: what it says of Aurora and of Presotto, and whether he is told | written in a neutral way, to be reviewed |

## Index of items

| Item | Subject | State |
|---|---|---|
| #1 | The form of a node | #1a, a uniform tree |
| #2 | How a node gets its rectangle | #2a, from the parent, with a `rect` |
| #3 | The leaves, `List` and `Table` | #3a, with no `:Table` |
| #4 | Style | #4a, inherited, in `color=[]` and `font=[]`, colors as tags |
| #5 | Sections | #5a, `:Section` |
| #6 | Steps | open again: #6a was implemented and removed (#45) |
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

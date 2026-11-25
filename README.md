# pico-slides

A presentation is a table, played by tasks.

`pico-slides` is an engine of slides in [Atmos][atmos], over
[pico][pico]. The author of a presentation writes a tree of tagged
nodes, as data, and the engine lays it out and shows it:

```
:Slides [
    font = [file="DejaVuSans.ttf"],

    :Slide [ title="Culture",
        :Row [
            :List [
                "Belly dance",
                "Djellaba",
            ],
            :Col [ :image ["a.jpg"], :image ["b.jpg"] ],
        ],
    ],
]
```

- A node is a table with a tag: its named fields are attributes, and
  its positional entries are its children.
- A tag in lower case draws (`:text`, `:image`); a tag in upper case
  arranges (`:Slide`, `:Row`, `:Col`, `:List`).
- A node receives a rectangle from its parent, and places itself in it
  with the anchors and the relative rectangles of pico.
- Colors, fonts, and spaces are inherited down the tree.
- A text that does not fit in its rectangle is an error, when the
  document is loaded.
- `anim=true` in a composite makes its children appear one per key,
  and `:Contents []` is the table of contents, made from the sections.
- A file may define names for what repeats, and `include` a theme with
  the names that many presentations share.

The format is in [`doc/design.md`](doc/design.md), with the decisions
behind it and what is still open.

**Experimental: work in progress.** The format and the engine may
change.

[atmos]: https://github.com/ia-atmos/lang
[pico]:  https://github.com/ia-atmos/env-pico

## Run

```
sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev \
    libsdl2-ttf-dev libsdl2-gfx-dev
./setup.sh                          # fetches and builds the compiler and pico
./slides exs/tour/tour.slides       # a tour, written in the format
```

`./slides [--fit=stretch|bars] <file> [<width> <height>]` plays a file
of data. The paths in the file (images, fonts) are relative to it.
`--fit=bars` keeps the proportion of a document with a fixed `aspect`
in a window of another one, with bars; the default stretches it.

`./slides --pdf <out.pdf> <file> [<width> <height>]` saves
the presentation as a PDF, with no window: each slide is drawn as on
the screen and becomes a page, an image of `1920x1080` if no dimension
is given.

| Key | Effect |
|---|---|
| Right, Down, Space, PageDown | the next step, or the next slide |
| Left, Up, Backspace, PageUp | the previous step, or the previous slide |
| Home, End | the first and the last slides |
| F | fullscreen |
| Escape, Q | quit |

A presentation may also be an Atmos program, which builds the table and
plays it. A template is then a function that builds nodes:

```
include "../../src/slides.atm"

func Cover (title, author) {
    :Slide [ color=[bg=:navy, fg=:white],
        :text [title,  font=[size=0.12], span=2, anchor=:S],
        :text [author, anchor=:N],
    ]
}

pin doc = :Slides [
    Cover("Templates", "are functions"),
]

pico.open()
await Slides.Play(doc)
```

See [`exs/program/main.atm`](exs/program/main.atm), which runs with
`deps/env-pico/atmos-pico main.atm` from its directory.

## Files

| Path | What |
|---|---|
| `src/slides.atm` | the engine: `Slides.check`, `Slides.layout`, `Slides.Play` |
| `src/main.atm` | plays a file of data, read with `X.loadx` |
| `slides` | runs `src/main.atm` from the directory of the file; `--pdf` writes a PDF |
| `tools/png2pdf.c` | joins images in a PDF, one per page |
| `setup.sh` | fetches the compiler and pico at fixed commits into `deps/`, and builds the tool |
| `doc/design.md` | the format, and the decisions |
| `exs/` | examples |
| `tst/` | tests: `tst/run.sh` |
| `res/` | a font for the tests and the examples |

## Tests

```
tst/run.sh              # all tests, headless (requires xvfb-run)
tst/run.sh text list    # only some
```

A visual test plays a document under scripted keys, saves the window at
some frames, and compares each image with its reference in `tst/asr/`.
An error test checks the message of a document that must be refused,
and a PDF test the number of pages of the file.
The references depend on the rendering of fonts, and may differ with
other versions of SDL and FreeType.

## Origin

The starting point is Aurora, the engine of slides of the final project
of Thiago Presotto Moreira (UERJ, 2025),
[`ThiPresotto/Reactive-Slides`][aurora], in which a presentation is a
Lua table played by Atmos tasks. `pico-slides` starts again from zero,
with a new format and new code, and takes from Aurora the idea and what
its experiments showed. The differences are in
[`doc/design.md`](doc/design.md#origin).

The design is of the author of this repository. The code, the tests,
and the documents were written with an AI assistant (Claude), under his
direction.

[aurora]: https://github.com/ThiPresotto/Reactive-Slides

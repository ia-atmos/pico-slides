# Design: the source table

A presentation is one table: a tree of tagged nodes. This document
records the design of that table, as decided with the author, and the
choices that the first engine made where nothing was decided.

Each decision carries its item (`#N`) from the design discussion.
Status: **draft, under discussion**. What the engine chose alone is in
[Provisional](#provisional), and what is not decided is in
[Open](#open).

## Origin

The starting point is Aurora, the slide engine of Thiago Presotto
(`ThiPresotto/Reactive-Slides`), in which a presentation is a Lua table
played by Atmos tasks. This design starts again from zero, with Aurora
as inspiration. What changes:

| Aurora | Here |
|---|---|
| `template` on a slide, `tag` on an object | one kind of node, with a tag |
| Two fixed levels (slide, objects) | a tree that nests freely |
| `Grid` as anonymous nested tables, empty tables as spacers | `:Row` and `:Col`, anchors, `span` |
| `xshift`, `yshift`, `size` | a `rect` of pico, relative to the parent |
| `Contents` as a table of slide numbers | `:Section` nodes in the tree |
| `color={fg,bg}`, `bgcolor`, `color` | one group `color=[fg=, bg=]`, inherited |

## The node (#1a)

Every node is a tagged table:

- the **tag** says what the node is;
- the **named fields** are its attributes;
- the **positional entries** are its children, or its content in a leaf.

```
:Slide [ title="Culture",       ;; tag, attribute
    "Morocco has ...",          ;; children
    :image ["dance.jpg"],
]
```

A tag in lower case is a primitive, which draws (`:text`, `:image`). A
tag that starts in upper case is a composite, which arranges its
children (`:Slide`, `:Row`).

The whole document is data: constructors, strings, numbers, and tags,
with no functions. It can be read with `X.load`.

## Grammar (#3a, #5a, #8a)

```
Slides  : :Slides  [ (Slide | Section)* ]
Section : :Section [ title=STR, Slide* ]
Slide   : :Slide   [ [title=(STR | Text)], Block* ]
Block   : :Row   [ Block* ]
        | :Col   [ Block* ]
        | :List  [ Block* ]
        | Text
        | :image [ STR ]            ;; the path of the file
        | STR                       ;; same as :text [ STR ]
Text    : :text  [ STR ]
```

| Level | Tags | Where | Contains |
|---|---|---|---|
| Document | `:Slides` | the root only | `:Slide`, `:Section` |
| Section | `:Section` | directly in `:Slides` | `:Slide` |
| Slide | `:Slide` | directly in `:Slides` or `:Section` | any block |
| Composite block | `:Row`, `:Col`, `:List` | anywhere inside a slide | any block |
| Leaf block | `:text`, `:image`, a string | anywhere inside a slide | its content only |

Not valid: a `:Slide` inside a block or another slide; a block directly
in `:Slides` or `:Section`; children in a leaf.

A block receives a rectangle and does not know who gave it: a `:Row`
behaves the same in a slide, in a `:Col`, or as an item of a `:List`.

## Layout

### The rectangle of a node (#2a)

- A composite gives a rectangle to each of its children.
- A node may have a field `rect`, a `Rect` of pico in mode `'%'`,
  relative to the rectangle it received.
- With no `rect`, a composite takes the whole rectangle, and a leaf
  takes its natural size, placed by its `anchor`.

```
:image ["map.png", rect=['%', x=1, y=1, w=0.3, anchor=:SE]]
```

### Composites (#8a)

- `:Row` splits its width: the children go side by side.
- `:Col` splits its height: the children go one below the other.
- `:Slide` stacks its children as a `:Col` does. A `:Col` is only
  needed inside a `:Row`.
- `:List` stacks its children, with a marker before each. An item is
  any block, so a list nests in a list.

In a `:Row`, `:Col`, and `:Slide`, the parts are equal, unless a child
has a `span`.

In a `:List`, the items go together (#28a):

- Each item has the height of its content, with the `gap` between
  them.
- The list goes to the point of its rectangle that its `anchor` gives,
  and to `:NW` if no node sets one.
- An item that is not a text (an `:image`, `:Row`, or `:Col`) has no
  height of its own: it needs `rect=['%', h=]`, relative to the height
  of the list.
- Items that pass the height of the rectangle are an error (#16).

```
:Slide [ title="Culture",
    :Row [
        "Morocco has ...",
        :Col [ :image ["a.jpg"], :image ["b.jpg"] ],
    ],
]
```

```
+---------------------------+
|          Culture          |   title
+---------------------------+
|             |    img a    |
|    text     +-------------+
|             |    img b    |
+---------------------------+
```

### Unequal parts: `span` (#13a, #19h)

A composite splits itself in equal units, as many as the sum of the
`span` of its children, and each child takes its number of units. The
default is `1`. The direction is that of the parent: the width in a
`:Row`, the height in a `:Col`, `:List`, or `:Slide`. A `span` is not
inherited.

```
:Slide [
    :text ["Morocco has ...", span=3],                  ;; 3/4 of the height
    :Row [ :image ["a.jpg"], :image ["b.jpg"] ],        ;; 1/4
]
```

### The size of a leaf (#12a, #18a)

- An **image** grows or shrinks until it fits whole in its rectangle,
  with its proportion kept. A `rect` with `w` or `h` reduces it.
- A **text** has the size of its font, which does not change with the
  amount of text. Its lines break at the width of the rectangle, and
  the breaks written in the string are kept.
- In the `rect` of a text, `h` is the height of **one line**, relative
  to the rectangle received, as in pico. It applies to that node only
  and prevails over `font=[size=]`.

```
:text ["BIG", rect=['%', h=0.5]]    ;; a line is half the height of the cell
```

### A text that does not fit (#16)

A text whose broken lines pass the height of its rectangle is an
**error**, always: when the document is loaded, for all slides, and
also if the window changes afterwards. The error says the slide, the
node, and by how much. Nothing is clipped, shrunk, or drawn over a
neighbor. An image never overflows, since it fits.

### Alignment: `anchor` (#10a)

The field `anchor` says at which point of its rectangle a leaf sits,
with the nine names of pico as tags: `:NW`, `:N`, `:NE`, `:W`, `:C`,
`:E`, `:SW`, `:S`, `:SE`.

- It is inherited down the tree, as the style is.
- The lines of a text with many lines follow its horizontal part
  (`:W` left, `:C` center, `:E` right).
- The default is `:C` at the root. A `:List` with no anchor set goes at
  `:NW` (#28a).
- `anchor` is the short and inherited form; `rect` is the fine
  adjustment of one node. `anchor=:W` is the same as
  `rect=['%', x=0, y=0.5, anchor=:W]`.

### Spaces: `cell` (#14a, #20a, #29)

```
cell = [ pad=NUM, gap=NUM ]
```

- `pad`: the inner space between the border of a node and its content.
  In a `:Slide`, it is the margin of the page.
- `gap`: the space between the children of a composite.
- Both are fractions of the height of the slide, so that the same value
  gives the same space in both directions.
- `gap` is inherited, field by field.
- `pad` is not inherited (#29): it holds only for the node that sets
  it, since otherwise every level of nesting would add the margin
  again. A `pad` in `:Slides` or `:Section` is the margin of their
  slides.

### The title (#15a)

- `title` is a field of the slide, not a child.
- The slide reserves a band at the top with the height that the title
  needs. The body takes the rest and splits it among the children.
- With no title there is no band.
- `title` is a string, or a `:text [...]` to give it a style of its
  own.

### The dimension of the slide (#17, #21, #22a, #25b)

Two fields of `:Slides`:

| Field | Value | Effect |
|---|---|---|
| `aspect` | absent | the slide follows the proportion of the window |
| `aspect` | `[w, h]`, as in `[16, 9]` | a fixed proportion |
| `fit` | `:stretch` (default) | the slide fills the window, deformed |
| `fit` | `:bars` | the slide is scaled until it fits whole; the rest is bars |

`fit` only matters with a fixed `aspect`. Its default is the same as in
pico. The resolution is that of the
window in all cases.

## Style (#4a, #9a)

Two groups, valid in any node:

```
color = [ fg=Color, bg=Color ]
font  = [ file=STR, size=NUM ]
```

| Group | Field | Value |
|---|---|---|
| `color` | `fg` | the color of the text: a tag (`:black`), or another color of pico |
| `color` | `bg` | the background of the rectangle of the node |
| `font` | `file` | the path of a TTF; absent, the built-in font of pico |
| `font` | `size` | the height of a line, as a fraction of the height of the slide |

- A field of style holds for the node and for everything inside it,
  until an inner node sets it again.
- Inheritance is field by field: `color=[bg=:red]` changes the
  background only, and `fg` still comes from the parent.

## Fields in summary

| Field | Where | Inherited |
|---|---|---|
| `aspect`, `fit` | `:Slides` | - |
| `title` | `:Slide`, `:Section` | no |
| `rect` | any block | no |
| `span` | any child of a composite | no |
| `anchor` | any node | yes |
| `color=[fg=, bg=]` | any node | yes, field by field |
| `font=[file=, size=]` | any node | yes, field by field |
| `cell=[gap=]` | any node | yes |
| `cell=[pad=]` | any node | no (from `:Slides` and `:Section` to their slides) |

## A complete example

```
:Slides [ aspect=[16, 9],
    color = [fg=:black, bg=:white],
    font  = [file="DejaVuSans.ttf", size=0.05],
    cell  = [pad=0.05, gap=0.02],

    :Slide [ title="Morocco", anchor=:C,
        "A school presentation",
    ],

    :Section [ title="The country",
        :Slide [ title="Geography", anchor=:W,
            :text ["Morocco is in the north of Africa ...", span=2],
            :image ["map.png", anchor=:E],
        ],
        :Slide [ title="Culture", color=[bg=:red],
            :Row [
                :List [
                    "Belly dance",
                    "Djellaba",
                    :List [ "wool", "with a hood" ],
                ],
                :Col [ :image ["a.jpg"], :image ["b.jpg"] ],
            ],
        ],
    ],

    :Section [ title="Traditions", color=[fg=:white, bg=:black],
        :Slide [
            :Row [ "In the flag ...", "Morocco is inhabited ..." ],
            :image ["flag.png"],
            :text  ["The main sports ...", font=[size=0.03]],
            :Row [ cell=[gap=0.01],
                :image ["s1.jpg"], :image ["s2.jpg"], :image ["s3.jpg"],
            ],
        ],
    ],
]
```

## Provisional

What the first engine chose where nothing was decided. Each waits for
the author.

| Item | Subject | What the engine does |
|---|---|---|
| #30 | Default values | `font.size=0.05`, `cell.pad=0.04` (the margin of a slide), `cell.gap=0.02`, `color=[fg=:black, bg=:white]`, a window of `960x540`. |
| #31 | The style of a title | 1.5 times the size of the text of its slide, centered at the top (`:N`). A `:text` as `title` sets its own `font`, `color`, and `anchor`. |
| #32 | The marker of a `:List` | A dot, drawn (not a character), so that it does not depend on the font. No field chooses it yet. |
| #34 | Blanks in a text | A text breaks between words, and the blanks between them collapse. The blanks that start a line are kept, as an indentation. |
| #35 | The height of a line | The size of a font is the height of a line, glyphs and leading together, so that `n` lines take exactly `n` times the size. |
| #36 | The keys | Right, Down, Space, PageDown: next. Left, Up, Backspace, PageUp: previous. Home, End. F: fullscreen. Escape, Q: quit. |

## The engine

In `src/slides.atm`, in three parts:

- **`Slides.check(doc)`** validates the document against the grammar
  and the fields above. An unknown field is an error, with the place
  of the node: `slides : slide 2 > 0:Row > 1:text : unknown field : colour`.
- **`Slides.layout(doc, w, h)`** resolves all slides for a world of
  `w` by `h` pixels. Each node becomes a **frame**: its rectangle in
  pixels, what is drawn in it (a background, lines of text, an image,
  the dots of a list), and the frames inside it. A text that does not
  fit is an error here (#16), for every slide, before the first one is
  shown.
- **`Slides.Play(doc)`** is a task. It checks, lays out, and shows the
  current slide as a tree of tasks, one per frame: a task draws its
  own frame on `:draw`, and holds the tasks of the frames inside it in
  a pool. A key changes the slide, which aborts the tasks of the
  previous one. A `:window.resize` lays everything out again.

A document is played from a file of data, read with `X.loadx`
(`./slides file`), or from an Atmos program that builds the table and
awaits `Slides.Play(doc)`, where a template is a function that builds
nodes (`exs/program/main.atm`).

## Open

Not decided. The first three were raised and set aside by the author.

| Item | Question | Proposed |
|---|---|---|
| #11 | How the table of contents appears in the source | a block `:Contents []`, expanded by the engine from the sections |
| - | References (the `Ref` table and the `Reference` slide of Aurora) | not discussed |
| #6 | Steps inside a slide (the `anim` of Aurora, the overlays of Beamer) | a field `step=N` in any block |
| #7 | Is the document only data, or may it carry functions | waits for `loadx` |
| - | A style for all titles at once | waits for `loadx` |
| - | Modes of `rect` other than `'%'` | not discussed |
| - | The fields of `:List` (the marker, numbering) | not discussed |
| - | `:Table` | left out for now (#3a) |
| - | A `:Grid` as a function that builds a `:Col` of `:Row` | later, if needed |

## Depends on other sessions

- **`X.loadx`** (session `atmos-loadx`, in `ia-atmos/lang`): a loader
  of data that accepts names, so that a value that repeats is written
  once. Agreed with the author on 2026-11-20 and in `main` of
  `ia-atmos/lang` (manual, section "Load with Names").

  ```
  Text  : { ID `=´ Value } Value
  Value : (as in X.load) | ID
  ```

  - A name is used as a value only: a positional entry, or the value
    of a field. There is **no spread** and no merge of fields.
  - Each use is a deep copy, so the result is still a tree.
  - A name sees only the names defined before it.

  ```
  BIG  = [ size=0.08 ]
  BLUE = [ fg=:blue ]
  LOGO = :image ["logo.png", anchor=:SE]

  :Slides [
      :Slide [ title=:text ["Culture", font=BIG, color=BLUE], LOGO ],
      :Slide [ LOGO ],
  ]
  ```

  The groups of style are values, so a name fits them directly
  (`font=BIG`). A name for a style that crosses groups needs a field
  of its own, which is open.
- **`fit` in pico** (session `env-pico`): done on 2026-11-20. It is a
  field of the scene of any layer, `pico.set.scene [ fit=:bars ]` or
  `fit=:stretch`, valid in a resized window and in fullscreen, so the
  `fit` of `:Slides` is passed straight to the world, with the same
  default (`:stretch`). The
  bars take the clear color of the window layer, and a point of the
  mouse on a bar is outside the world. In pico, enums are now written
  as tags (`:red`, `:NW`), as in this document.

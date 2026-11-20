# Design: the source table

A presentation is one table: a tree of tagged nodes. This document
records the design of that table, as decided with the author. It covers
the source format only; the engine that plays it is not designed yet.

Each decision carries its item (`#N`) from the design discussion.
Status: **draft, under discussion**. What is not decided is in
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
- `:List` stacks its children as a `:Col` does, with a marker before
  each. An item is any block, so a list nests in a list.

The parts are equal, unless a child has a `span`.

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
- The default is `:C` at the root. A `:List` changes the default of its
  items to `:W`.
- `anchor` is the short and inherited form; `rect` is the fine
  adjustment of one node. `anchor=:W` is the same as
  `rect=['%', x=0, y=0.5, anchor=:W]`.

### Spaces: `cell` (#14a, #20a)

```
cell = [ pad=NUM, gap=NUM ]
```

- `pad`: the inner space between the border of a node and its content.
  In a `:Slide`, it is the margin of the page.
- `gap`: the space between the children of a composite.
- Both are fractions of the height of the slide, so that the same value
  gives the same space in both directions.
- The group is inherited field by field.

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
| `cell=[pad=, gap=]` | any node | yes, field by field |

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

## Open

Not decided. The first three were raised and set aside by the author.

| Item | Question | Proposed |
|---|---|---|
| #11 | How the table of contents appears in the source | a block `:Contents []`, expanded by the engine from the sections |
| - | References (the `Ref` table and the `Reference` slide of Aurora) | not discussed |
| #6 | Steps inside a slide (the `anim` of Aurora, the overlays of Beamer) | a field `step=N` in any block |
| #7 | Is the document only data, or may it carry functions | waits for `loadx` |
| - | A style for all titles at once | waits for `loadx` |
| - | The default values (`font.size`, `cell.pad`, `cell.gap`) | to be set with the engine |
| - | Modes of `rect` other than `'%'` | not discussed |
| - | The fields of `:List` (the marker, numbering) | not discussed |
| - | `:Table` | left out for now (#3a) |
| - | A `:Grid` as a function that builds a `:Col` of `:Row` | later, if needed |

## Depends on other sessions

- **`loadx`** (session `atmos-loadx`, in `ia-atmos/lang`): a loader of
  data that accepts names and spread, so that a style or a block that
  repeats is written once:

  ```
  TITLE = [ font=[size=0.08], color=[fg=:blue] ]
  :Slides [
      :Slide [ title=:text ["Culture", TITLE...], ... ],
  ]
  ```

  Proposed there on 2026-11-19; its syntax and semantics are not
  decided.
- **`fit` in pico** (session `env-pico`): done on 2026-11-20. It is a
  field of the scene of any layer, `pico.set.scene [ fit=:bars ]` or
  `fit=:stretch`, valid in a resized window and in fullscreen, so the
  `fit` of `:Slides` is passed straight to the world, with the same
  default (`:stretch`). The
  bars take the clear color of the window layer, and a point of the
  mouse on a bar is outside the world. In pico, enums are now written
  as tags (`:red`, `:NW`), as in this document.

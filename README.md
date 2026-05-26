# HAML for Nova

Tree-sitter based syntax highlighting for HAML templates, built on
[vitallium/tree-sitter-haml](https://github.com/vitallium/tree-sitter-haml) (MIT).

Highlighting only — tags, classes/IDs, attributes, embedded Ruby (with
injection into Nova's Ruby grammar), filters, doctypes, comments, and
Ruby variable flavors.

## What's in the box

```
.
├── build.sh                       ← run this on your Mac
├── parser-src/                    ← pre-generated parser (no codegen needed)
│   ├── parser.c
│   ├── scanner.c                  ← external scanner (HAML indentation)
│   └── tree_sitter/               ← headers
└── HAML.novaextension/            ← the extension bundle
    ├── extension.json
    ├── Syntaxes/HAML.xml
    ├── Queries/highlights.scm
    ├── Queries/injections.scm
    └── Tests/test.haml
```

The parser C source is already generated and has been verified to compile,
so you do **not** need the tree-sitter CLI, Node, or any codegen step.
All that's left is the one step that requires your machine: linking against
Nova's bundled SyntaxKit framework and codesigning.

## Build

Requires: macOS with Xcode Command Line Tools (`xcode-select --install`)
and Nova installed at `/Applications/Nova.app`.

```bash
chmod +x build.sh
./build.sh
# or, if Nova lives elsewhere:
./build.sh /path/to/Nova.app
```

This produces `HAML.novaextension/Syntaxes/libtree-sitter-haml.dylib`.

## Install / test

1. In Nova: **Extensions → Open Extensions Folder**, or just open the
   `HAML.novaextension` folder as a project.
2. **Extensions → Activate Project as Extension** (developer mode — reloads
   on file change).
3. Open `Tests/test.haml`. You should see tags, classes, Ruby, and filters
   colored.
4. If something looks off, **Extensions → Show Extension Console** surfaces
   parser/query errors.

For a permanent install, copy `HAML.novaextension` into Nova's extensions
folder (Extensions → Open Extensions Folder).

## Notes / known rough edges

- Scope names in `Queries/highlights.scm` follow Nova's documented set, but
  exact theme coloring varies by theme. If a node type isn't picking up a
  color you like, tweak the `@scope` on that line — it's plain text, easy to
  edit.
- `injections.scm` asks Nova to highlight embedded Ruby with its built-in
  Ruby grammar and filter bodies (`:javascript`, `:css`) by their language
  hint. Filter-body injection depends on Nova having that grammar available.
- This is highlighting only — no completion, folding, or symbol nav. That was
  the goal.

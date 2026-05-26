# nova-haml

Tree-sitter based syntax highlighting for [HAML](https://haml.info/) templates
in [Nova](https://nova.app/), Panic's macOS editor.

When this was written, the Nova Extension Library had no HAML support. This
fills that gap: full tree-sitter highlighting for tags, classes, attributes,
doctypes, comments, filters, and embedded Ruby — with the embedded Ruby parsed
by Nova's built-in Ruby grammar (so method calls, strings, symbols, and
variables are highlighted individually, not as one flat blob).

Highlighting only — no completion, folding, or symbol navigation. That's by
design; if you want those, this is a good base to build on.

## Features

- Tags (`%div`, `%span`), classes (`.foo`), and IDs
- Attribute hashes — `{foo: "bar"}` and `(key="val")`
- Doctypes (`!!! 5`)
- Comments — both silent (`-#`) and HTML (`/`)
- Filters (`:javascript`, `:css`, `:ruby`, …)
- Embedded Ruby, highlighted via injection into Nova's built-in Ruby grammar
- Ruby interpolation (`#{...}`) inside text and attributes
- `⌘/` comment toggling using HAML's silent `-#` comment

## Install

### From the Extension Library

Search for "HAML" in Nova's Extension Library and click Install.

### From a release

Download the latest `HAML.novaextension.zip` from
[Releases](https://github.com/mindtonic/nova-haml/releases), unzip, and
**double-click** `HAML.novaextension` — macOS hands it to Nova, which installs
it. Relaunch Nova, then open any `.haml` file.

The released bundle includes a pre-built **universal** `libtree-sitter-haml.dylib`
(arm64 + x86_64), so it runs on both Apple Silicon and Intel Macs. If it ever
fails to load — for example after a future Nova update — rebuild it yourself;
see "Build from source" below.

### Build from source

Requires macOS with Xcode Command Line Tools (`xcode-select --install`) and
Nova installed at `/Applications/Nova.app`.

```bash
git clone https://github.com/mindtonic/nova-haml.git
cd nova-haml
./build.sh                 # or: ./build.sh /path/to/Nova.app
```

`build.sh` compiles the pre-generated parser in `parser-src/` as a universal
binary, links it against Nova's bundled `SyntaxKit` framework, codesigns it
(ad-hoc), and writes `HAML.novaextension/Syntaxes/libtree-sitter-haml.dylib`.
The tree-sitter CLI is **not** required — the parser C source is already
generated and committed.

Then double-click `HAML.novaextension` to install, and relaunch Nova.

## Project layout

```
nova-haml/
├── build.sh                  # compile the parser dylib (run on your Mac)
├── parser-src/               # pre-generated parser.c + scanner.c + headers
├── HAML.novaextension/       # the extension bundle
│   ├── extension.json
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── extension.png
│   ├── Syntaxes/HAML.xml      # syntax definition + tree-sitter linkage
│   ├── Queries/highlights.scm # node → highlight-scope mapping
│   ├── Queries/injections.scm # embedded-Ruby / filter injection
│   └── Tests/test.haml        # a file exercising the features
├── LICENSE                   # this extension's license (MIT)
└── LICENSES/
    └── tree-sitter-haml-LICENSE  # upstream grammar's MIT license
```

> Note: the compiled `.dylib` is not committed to the repo — it's built by
> `build.sh` and attached to releases. The repo ships source only.

## Customizing colors

Highlight colors come from your active Nova theme, not this extension. Each
node is mapped to a theme *scope* in `Queries/highlights.scm` (e.g.
`(tag_name) @identifier.type`). If a token isn't colored the way you'd like,
turn on **Editor → Syntax Inspector**, hover the token to see its current
scope and the theme style applied, then change the `@scope` on that line to a
different one your theme paints. Reinstall to apply.

## Credits

Built on [`tree-sitter-haml`](https://github.com/vitallium/tree-sitter-haml)
by Vitaly Slobodin (MIT). The grammar's original license is preserved in
`LICENSES/`.

## Notes for anyone building a Nova tree-sitter syntax

A few things that cost real time and aren't obvious from the docs:

- **`min_runtime` is required.** Tree-sitter syntaxes need `"min_runtime":
  "10.0"` (or higher) in `extension.json`. Without it, Nova silently treats the
  extension as a legacy regex grammar, ignores the `<tree-sitter>` block, and
  the syntax never loads — with **no error in the Extension Console**.
- **Escape regex metacharacters in `<indentation>` expressions.** An unescaped
  `#` in an indentation regex (e.g. `[%.#]`) silently invalidates the *entire*
  syntax definition — highlighting, comments, everything — again with no
  console error. Escape it: `[%.\#]`. This one bug is why this extension took
  far longer to ship than it should have.
- **Injection captures use Nova's names.** Embedded-language injection requires
  `@injection.content` for the region and `(#set! injection.language "...")`
  for the language — not the bare `@content` / `language` names some
  tree-sitter docs show.
- **Theme scopes are theme-specific.** A query can match a node perfectly and
  still show no color if your theme doesn't style that scope. Use the Syntax
  Inspector to confirm both the matched scope *and* whether the theme paints it.
- **The Library requires a universal binary.** Submission rejects an
  arm64-only dylib; compile with `-arch arm64 -arch x86_64`.

## License

MIT. See `LICENSE`. Bundled grammar is MIT, see `LICENSES/`.

# bin-scripts

A growing collection of small command-line utilities I use from my personal `~/bin` on **macOS**.
These scripts are designed for quick, practical workflows (e.g., compiling/running small C programs, previewing Markdown, exporting PDFs).
New commands will be added over time.

## Contents

- `crun` — compile & run a C file quickly (optionally keep the binary)
- `cprun` — compile & run a C++ file quickly (optionally keep the binary)
- `md`   — Markdown → HTML preview (cached under `~/.cache/md`) and open in browser, or export a PDF with `-p` / a standalone HTML with `-H` into the current directory
- `ch` — open files/URLs in Google Chrome (instead of the default browser)

---

## Installation (macOS)

Clone into `~/bin` and make sure it is on your `PATH` (e.g., in `~/.zshrc`):

```zsh
git clone https://github.com/YoshitoSuzuki/bin.git ~/bin
export PATH="$HOME/bin:$PATH"
```

Everything the scripts need from this repository is bundled (including the CSS theme for `md`), so cloning is enough — plus the external tools below.

### External tools (not in this repository)

```zsh
brew install pandoc      # md: Markdown conversion
xcode-select --install   # crun / cprun: C/C++ compilers (also provides python3, used by md -w)
```

- **Google Chrome** at `/Applications/Google Chrome.app` — used by `md -p` for PDF export
- **KaTeX** (optional) — offline math rendering for `md`. Without it, math falls back to MathJax via CDN (needs network):

```zsh
mkdir -p ~/.config/md
curl -sL https://github.com/KaTeX/KaTeX/releases/latest/download/katex.tar.gz | tar xz -C ~/.config/md/
```

***

## Requirements

### `crun` / `cprun`

- `gcc` for `crun`, `g++` for `cprun`

### `md`

- `zsh`
- `pandoc`
- Google Chrome for `-p` (used in headless mode to print HTML to PDF)
- `python3` for `-w` (serves the preview for auto-reload)
- CSS theme is bundled (`assets/qiita.css`); see Customization to override it

***

## Commands

## 1) `crun` / `cprun` — compile & run a C / C++ file quickly

`crun` compiles `NAME.c` with `gcc`, `cprun` compiles `NAME.cpp` with `g++`.

### Usage

```bash
crun hello        # or: crun hello.c
cprun hello       # or: cprun hello.cpp
```

- Compiles `hello.c` (or `hello.cpp`) to `./hello`, runs it, then removes `./hello`.

Keep the compiled binary:

```bash
crun -b hello
```

- Compiles and runs, but keeps `./hello`.

***

## 2) `md` — Markdown to HTML/PDF preview (cached)

Convert a Markdown file to HTML and open it (or export a PDF with `-p`).
Outputs are stored under a cache directory next to the input file.

### Usage

```bash
md notes.md         # convert & open in browser
md -t notes.md      # with table of contents
md -w notes.md      # watch mode: regenerate on save, browser reloads only on change
md -p report.md     # write ./report.pdf (via headless Chrome) and open it
md -H notes.md      # write ./notes.html (standalone) and print its path (no browser)
md a.md b.md c.md   # multiple files at once
```

`-w` takes a single file. `-w`, `-p` and `-H` cannot be combined with each other.

### Output

- Preview HTML (cache): `~/.cache/md/<name>-<hash>/<name>.html` — never written next to your Markdown, so working directories stay clean. The hash is derived from the input file's absolute path, so same-named files in different directories get their own cache.
- Explicit exports go to the **current directory**: `./notes.html` with `-H`, `./report.pdf` with `-p`.

The generated HTML is fully self-contained: images, CSS and KaTeX (fonts included) are embedded as data URIs, so it has **zero external references**. It renders correctly from the cache directory, works offline, and looks exactly the same when served over HTTP.

Cached previews can be discarded at any time (`rm -rf ~/.cache/md`); they are regenerated on the next run.

### Publishing on the web (`-H`)

`-H` writes that self-contained HTML into the current directory and prints its absolute path instead of opening a browser, so you can upload the single file as-is:

```bash
scp "$(md -H notes.md)" server:/var/www/html/notes.html
```

Progress messages go to stderr, so the path is safe to use in a command substitution. If KaTeX is not installed, math falls back to MathJax via CDN — the file is then no longer self-contained, and `-H` warns about it.

The script regenerates outputs only when inputs are newer than cached files (or when options changed since the last run).

### Math (offline)

If KaTeX is installed at `~/.config/md/katex/`, TeX math (`$...$`, `$$...$$`) is rendered locally with no network needed. To install:

```bash
curl -sL https://github.com/KaTeX/KaTeX/releases/latest/download/katex.tar.gz | tar xz -C ~/.config/md/
```

Without it, the script falls back to MathJax via CDN.

***

## Customization

### Markdown CSS theme

`md` uses the bundled `assets/qiita.css` by default. To customize it without touching the repository, put your own CSS at:

- `~/.config/md/qiita.css`

If that file exists, it takes precedence over the bundled one.

***

## Adding new commands

I plan to keep adding scripts. If you add a new command, please consider:

- Use a clear filename (this becomes the command name)
- Add a small header comment: purpose, usage, dependencies
- Keep dependencies minimal and document them here
- Prefer safe defaults (avoid destructive operations)

***

## License

MIT License © Yoshito Suzuki

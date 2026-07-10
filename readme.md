# bin-scripts

A growing collection of small command-line utilities I use from my personal `~/bin` on **macOS**.
These scripts are designed for quick, practical workflows (e.g., compiling/running small C programs, previewing Markdown, exporting PDFs).
New commands will be added over time.

## Contents

- `crun` — compile & run a C file quickly (optionally keep the binary)
- `cprun` — compile & run a C++ file quickly (optionally keep the binary)
- `md`   — Markdown → HTML preview (cached) and open in browser, or export PDF with `-p`

---

## Installation (macOS)

### Clone + symlink into `~/bin` (recommended)

```zsh
git clone https://github.com/YoshitoSuzuki/bin.git
cd bin

chmod +x {filenames}
````

Make sure `~/bin` is on your `PATH` (e.g., in `~/.zshrc`):

```zsh
export PATH="$HOME/bin:$PATH"
```

***

## Requirements

### `crun` / `cprun`

- `gcc` for `crun`, `g++` for `cprun`

### `md`

- `zsh`
- `pandoc`
- CSS file for styling (default path used by the script):
  - `~/.config/md/qiita.css`
- Google Chrome for `-p` (used in headless mode to print HTML to PDF)
- `python3` for `-w` (serves the preview for auto-reload)

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
md -p report.md     # export PDF (via headless Chrome) and open it
md a.md b.md c.md   # multiple files at once
```

`-w` takes a single file and cannot be combined with `-p`.

### Output

- `./.md_cache/notes.html` (and `./.md_cache/report.pdf` with `-p`)

The generated HTML is fully self-contained: images, CSS and KaTeX are embedded, so it renders correctly from the cache directory and works offline.

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

By default, the script expects:

- `~/.config/md/qiita.css`

You can change the path inside the script or replace the CSS file.

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

# bin-scripts

A growing collection of small command-line utilities I use from my personal `~/bin` on **macOS**.
These scripts are designed for quick, practical workflows (e.g., compiling/running small C programs, previewing Markdown, exporting PDFs).
New commands will be added over time.

## Contents

- `crun` — compile & run a C file quickly (optionally keep the binary)
- `md`   — Markdown → HTML preview (cached) and open in browser
- `mdf`  — Markdown → PDF (via HTML + headless Chrome) and open the PDF

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

### `crun`

- `gcc` (or a compatible C compiler)

### `md` / `mdf`

- `zsh`
- `pandoc`
- CSS file for styling (default path used by the scripts):
  - `~/.config/md/qiita.css`

### `mdf` (PDF export)

- Google Chrome (used in headless mode to print HTML to PDF)

***

## Commands

## 1) `crun` — compile & run a C file quickly

Compile and run `NAME.c` by specifying `NAME`.

### Usage

```bash
crun hello
```

- Compiles `hello.c` to `./hello`, runs it, then removes `./hello`.

Keep the compiled binary:

```bash
crun -b hello
```

- Compiles and runs, but keeps `./hello`.

***

## 2) `md` — Markdown to HTML preview (cached)

Convert a Markdown file to HTML and open it.
The HTML is stored under a cache directory next to the input file.

### Usage

```bash
md notes.md      # convert & open
md -t notes.md   # with table of contents
md -w notes.md   # watch mode: regenerate on save, browser auto-reloads
```

### Output

- `./.md_cache/notes.html`

The script regenerates HTML only when the Markdown file is newer than the cached HTML.

### Math (offline)

If KaTeX is installed at `~/.config/md/katex/`, TeX math (`$...$`, `$$...$$`) is rendered locally with no network needed. To install:

```bash
curl -sL https://github.com/KaTeX/KaTeX/releases/latest/download/katex.tar.gz | tar xz -C ~/.config/md/
```

Without it, the script falls back to MathJax via CDN.

***

## 3) `mdf` — Markdown to PDF (via HTML + headless Chrome)

Convert Markdown to HTML (cached), then export PDF using headless Chrome, and open the PDF.

### Usage

```bash
mdf report.md
```

### Output

- `./.md_cache/report.html`
- `./.md_cache/report.pdf`

The script regenerates outputs only when inputs are newer than cached files.

***

## Customization

### Markdown CSS theme

By default, the scripts expect:

- `~/.config/md/qiita.css`

You can change the path inside the scripts or replace the CSS file.

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

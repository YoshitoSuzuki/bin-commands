#!/bin/zsh
# description: Markdown to HTML preview (cached)

usage() {
  echo "Usage: md [-w] [-t] <file.md>"
  echo "  -w  watch mode (auto-regenerate & reload)"
  echo "  -t  add table of contents"
  exit 1
}

WATCH=0
TOC=()
while getopts "wt" opt; do
  case $opt in
    w) WATCH=1 ;;
    t) TOC=(--toc --toc-depth=3) ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "$1" ]; then
  usage
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "File not found: $INPUT"
  exit 1
fi

DIR=$(dirname "$INPUT")
BASE=$(basename "$INPUT" .md)

OUT_DIR="$DIR/.md_cache"
mkdir -p "$OUT_DIR"

HTML="$OUT_DIR/$BASE.html"

CSS="$HOME/.config/md/qiita.css"
KATEX="$HOME/.config/md/katex"

# 数式: ローカルKaTeXがあれば使う（オフラインで動く）、なければMathJax(CDN)
if [ -d "$KATEX" ]; then
  MATH="--katex=file://$KATEX/"
else
  MATH="--mathjax"
fi

RELOAD=()
if [ $WATCH -eq 1 ]; then
  RELOAD_HTML="$OUT_DIR/.reload.html"
  echo '<script>setInterval(() => location.reload(), 1500)</script>' > "$RELOAD_HTML"
  RELOAD=(--include-after-body="$RELOAD_HTML")
fi

# 目次を最初のh1の直後に移動する
TOC_MOVE=()
if [ ${#TOC} -gt 0 ]; then
  TOC_HTML="$OUT_DIR/.toc.html"
  cat > "$TOC_HTML" <<'EOF'
<script>document.addEventListener("DOMContentLoaded", () => {
  const toc = document.getElementById("TOC");
  const h1 = document.querySelector("h1");
  if (toc && h1) h1.after(toc);
});</script>
EOF
  TOC_MOVE=(--include-after-body="$TOC_HTML")
fi

gen() {
  pandoc "$INPUT" -o "$HTML" \
    --css="$CSS" \
    --standalone \
    "$MATH" \
    --syntax-highlighting=pygments \
    --metadata pagetitle="$BASE" \
    $TOC $TOC_MOVE $RELOAD
}

# オプションが前回と変わっていたら再生成する
OPTS_FILE="$OUT_DIR/.$BASE.opts"
OPTS="toc=${#TOC} watch=$WATCH"

# HTML生成
if [ ! -f "$HTML" ] || [ "$INPUT" -nt "$HTML" ] || [ "$(cat "$OPTS_FILE" 2>/dev/null)" != "$OPTS" ]; then
  echo "Generating HTML..."
  gen && echo "$OPTS" > "$OPTS_FILE"
fi

# command
open "$HTML" &

# 監視モード: 保存のたびに再生成（ブラウザ側は自動リロード）
if [ $WATCH -eq 1 ]; then
  echo "Watching $INPUT (Ctrl-C to stop)"
  while sleep 1; do
    if [ "$INPUT" -nt "$HTML" ]; then
      gen && echo "Updated: $(date +%T)"
    fi
  done
fi

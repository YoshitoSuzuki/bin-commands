#!/bin/zsh
# description: Markdown to HTML/PDF preview (cached)

usage() {
  echo "Usage: md [-w] [-t] [-p] <file.md> ..."
  echo "  -w  watch mode (auto-regenerate & reload)"
  echo "  -t  add table of contents"
  echo "  -p  open as PDF (headless Chrome) instead of HTML"
  exit 1
}

WATCH=0
PDF=0
TOC=()
while getopts "wtp" opt; do
  case $opt in
    w) WATCH=1 ;;
    t) TOC=(--toc --toc-depth=3) ;;
    p) PDF=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
  usage
fi

if [ $WATCH -eq 1 ] && [ $PDF -eq 1 ]; then
  echo "-w and -p cannot be combined" >&2
  exit 1
fi

if [ $WATCH -eq 1 ] && [ $# -gt 1 ]; then
  echo "watch mode takes a single file" >&2
  exit 1
fi

CSS="$HOME/.config/md/qiita.css"
KATEX="$HOME/.config/md/katex"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# 数式: ローカルKaTeXがあれば使う（オフラインで動く）、なければMathJax(CDN)
if [ -d "$KATEX" ]; then
  MATH="--katex=file://$KATEX/"
else
  MATH="--mathjax"
fi

gen() {
  pandoc "$INPUT" -o "$HTML" \
    --css="$CSS" \
    --standalone \
    --embed-resources \
    --resource-path="$DIR" \
    "$MATH" \
    --syntax-highlighting=pygments \
    --metadata pagetitle="$BASE" \
    $TOC $TOC_MOVE $RELOAD
}

for INPUT in "$@"; do
  if [ ! -f "$INPUT" ]; then
    echo "File not found: $INPUT" >&2
    exit 1
  fi

  DIR=$(dirname "$INPUT")
  BASE="${$(basename "$INPUT")%.*}"

  OUT_DIR="$DIR/.md_cache"
  mkdir -p "$OUT_DIR"

  HTML="$OUT_DIR/$BASE.html"

  # 監視モード: 変更があったときだけリロードする（Last-Modifiedをローカルサーバー越しに比較）
  RELOAD=()
  if [ $WATCH -eq 1 ]; then
    RELOAD_HTML="$OUT_DIR/.reload.html"
    cat > "$RELOAD_HTML" <<'EOF'
<script>let last = null;
setInterval(async () => {
  try {
    const r = await fetch(location.pathname, {method: "HEAD", cache: "no-store"});
    const t = r.headers.get("last-modified");
    if (last && t !== last) location.reload();
    last = t;
  } catch (e) {}
}, 1000);</script>
EOF
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

  # オプションが前回と変わっていたら再生成する
  OPTS_FILE="$OUT_DIR/.$BASE.opts"
  OPTS="toc=${#TOC} watch=$WATCH"

  # HTML生成
  if [ ! -f "$HTML" ] || [ "$INPUT" -nt "$HTML" ] || [ "$(cat "$OPTS_FILE" 2>/dev/null)" != "$OPTS" ]; then
    echo "Generating HTML..."
    if ! gen; then
      echo "pandoc failed: $INPUT" >&2
      exit 1
    fi
    echo "$OPTS" > "$OPTS_FILE"
  fi

  if [ $PDF -eq 1 ]; then
    # PDF生成（Chrome）。virtual-time-budgetでKaTeX/MathJaxの描画完了を待つ
    if [ ! -x "$CHROME" ]; then
      echo "Google Chrome not found: $CHROME" >&2
      exit 1
    fi
    PDF_OUT="$OUT_DIR/$BASE.pdf"
    if [ ! -f "$PDF_OUT" ] || [ "$HTML" -nt "$PDF_OUT" ]; then
      echo "Generating PDF (Chrome)..."
      "$CHROME" \
        --headless \
        --disable-gpu \
        --virtual-time-budget=8000 \
        --print-to-pdf="$PDF_OUT" \
        --no-pdf-header-footer \
        "$HTML" || exit 1
    fi
    open "$PDF_OUT"
  elif [ $WATCH -eq 0 ]; then
    open "$HTML"
  fi
done

# 監視モード: 保存のたびに再生成。ローカルサーバーで配信し、ブラウザ側は更新時のみリロード
if [ $WATCH -eq 1 ]; then
  PORT=$((49152 + $(cksum <<< "${HTML:A}" | cut -d' ' -f1) % 10000))
  python3 -m http.server "$PORT" --directory "$OUT_DIR" >/dev/null 2>&1 &
  SERVER_PID=$!
  trap 'kill $SERVER_PID 2>/dev/null' EXIT
  trap 'exit' INT TERM

  URL="http://localhost:$PORT/$(python3 -c 'import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))' "$BASE.html")"
  for _ in {1..20}; do
    curl -s -o /dev/null "$URL" && break
    sleep 0.1
  done
  open "$URL"

  echo "Watching $INPUT (Ctrl-C to stop)"
  LAST=$(stat -f %m "$INPUT")
  while sleep 1; do
    NOW=$(stat -f %m "$INPUT")
    if [ "$NOW" != "$LAST" ]; then
      LAST=$NOW
      if gen; then
        echo "Updated: $(date +%T)"
      else
        echo "pandoc failed: $(date +%T)" >&2
      fi
    fi
  done
fi

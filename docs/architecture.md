# architecture — 各コマンドの仕組み

最終更新: 2026-07-10

すべて zsh スクリプト。1コマンド = 1ファイルで、ファイル名がそのままコマンド名。

## md（Markdown → HTML / PDF プレビュー）

旧 `mdf`（PDF 化）は 2026-07-10 に `md -p` として統合した。

処理の流れ:

1. 入力 `foo.md` と同じディレクトリに `.md_cache/` を作る
2. pandoc で `foo.md` → `.md_cache/foo.html` に変換
   - CSS: `~/.config/md/qiita.css`
   - シンタックスハイライト: pygments スタイル
   - 数式: `~/.config/md/katex/` が存在すればローカル KaTeX（`--katex=file://...`）、なければ MathJax（CDN、要ネット）
   - `--embed-resources` で画像・CSS・KaTeX 一式をすべて HTML に埋め込む（data URI 化）。HTML が `.md_cache/` に置かれても相対パスの画像が壊れないため。1ファイル 1.5MB 程度になるがプレビュー用キャッシュなので許容。`--resource-path` で画像は入力 md のディレクトリ基準に解決される（どこから実行しても効く）
3. `open` でデフォルトブラウザで開く（`-p` のときは PDF を開く）

複数ファイルをまとめて渡せる（`md a.md b.md`）。ただし `-w` は1ファイルのみ、`-w` と `-p` の併用は不可。pandoc が失敗したときは古いキャッシュを開かず exit 1 する。

キャッシュ: HTML より Markdown が新しいとき、または**前回とオプションが違うとき**に再生成する。前回のオプションは `.md_cache/.<名前>.opts` に記録してあり、`md foo.md` → `md -t foo.md` のような打ち直しでもちゃんと反映される。

オプション:

- `-t` — pandoc の `--toc --toc-depth=3` を付けて目次を生成。pandoc は目次を本文の先頭（タイトルの上）に置くので、埋め込んだ JS で最初の `<h1>` の直後に移動している
- `-w` — 監視モード。1秒ごとに mtime を見て、更新されていたら再生成。`python3 -m http.server`（ポートは HTML の絶対パスの cksum から 49152〜59151 に決まる）で `.md_cache/` を配信し、ブラウザはその URL を開く。HTML 側には `.md_cache/.reload.html` 経由で「1秒ごとに自分の Last-Modified を HEAD で見て、変わったときだけ location.reload() する `<script>`」を埋め込む（無変更時にリロードしないのでチラつかない。`fetch` が必要なので file:// ではなくサーバー配信にしている）。Ctrl-C で終了するとサーバーも trap で落ちる
- `-p` — PDF 化（旧 mdf）。headless Chrome（`/Applications/Google Chrome.app/...` を直接パス指定）で `--print-to-pdf` する。`--virtual-time-budget=8000` で KaTeX/MathJax の JS 描画完了を待ってから印刷するので、数式が未描画のまま PDF になることはない。PDF もキャッシュ式（HTML が PDF より新しいときだけ再生成）

## 数式サポート（2026-07-08 追加）

- KaTeX v0.17.0 を `~/.config/md/katex/`（フォント込み約3MB）に配置してある
- pandoc の `--katex=file://$HOME/.config/md/katex/` で、生成 HTML がローカルの katex.min.js / katex.min.css を読む → **完全オフラインで数式が描画できる**
- KaTeX ディレクトリがないマシンでは自動で `--mathjax`（CDN）にフォールバックするので、スクリプト自体はどこでも動く
- 対応記法: `$...$`（インライン）、`$$...$$`（ディスプレイ）

## crun / cprun（C / C++ 即実行）

crun は `gcc` + `.c`、cprun は `g++` + `.cpp` 用。コンパイルしてすぐ実行し、実行後にバイナリを消す。`-b` を付けるとバイナリを残す。

- `crun hello.c` でも `crun hello`（拡張子なし）でも動く。拡張子が strip できなかったら「拡張子なしで指定された」とみなして補完する
- この補完は安全対策でもある: 以前は拡張子が strip できないと `gcc -o foo.c foo.c` のようにソースファイルを実行ファイルで上書きする事故が起きた（2026-07-08 に修正済み。それ以前の crun は中身が cprun と同一の C++ 用だった）

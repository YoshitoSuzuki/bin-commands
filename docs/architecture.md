# architecture — 各コマンドの仕組み

最終更新: 2026-07-08

すべて zsh スクリプト。1コマンド = 1ファイルで、ファイル名がそのままコマンド名。

## md（Markdown → HTML プレビュー）

処理の流れ:

1. 入力 `foo.md` と同じディレクトリに `.md_cache/` を作る
2. pandoc で `foo.md` → `.md_cache/foo.html` に変換
   - CSS: `~/.config/md/qiita.css`
   - シンタックスハイライト: pygments スタイル
   - 数式: `~/.config/md/katex/` が存在すればローカル KaTeX（`--katex=file://...`）、なければ MathJax（CDN、要ネット）
3. `open` でデフォルトブラウザで開く

キャッシュ: HTML より Markdown が新しいとき、または**前回とオプションが違うとき**に再生成する。前回のオプションは `.md_cache/.<名前>.opts` に記録してあり、`md foo.md` → `md -t foo.md` のような打ち直しでもちゃんと反映される。

オプション:

- `-t` — pandoc の `--toc --toc-depth=3` を付けて目次を生成。pandoc は目次を本文の先頭（タイトルの上）に置くので、埋め込んだ JS で最初の `<h1>` の直後に移動している
- `-w` — 監視モード。1秒ごとに mtime を見て、更新されていたら再生成。HTML 側には `.md_cache/.reload.html` 経由で「1.5秒ごとに location.reload() する `<script>`」を埋め込むので、ブラウザが勝手に追従する。fswatch 等の外部ツールは不要。Ctrl-C で終了

## mdf（Markdown → PDF）

1. md と同じ方法で HTML を生成（数式のローカル KaTeX 対応も同じ）
2. headless Chrome（`/Applications/Google Chrome.app/...` を直接パス指定）で `--print-to-pdf` する。Chrome は JS を実行してから印刷するので、KaTeX で描画済みの数式が PDF に入る
3. `open` で PDF を開く

こちらもキャッシュ式（md が HTML より新しければ HTML 再生成、HTML が PDF より新しければ PDF 再生成）。

## 数式サポート（2026-07-08 追加）

- KaTeX v0.17.0 を `~/.config/md/katex/`（フォント込み約3MB）に配置してある
- pandoc の `--katex=file://$HOME/.config/md/katex/` で、生成 HTML がローカルの katex.min.js / katex.min.css を読む → **完全オフラインで数式が描画できる**
- KaTeX ディレクトリがないマシンでは自動で `--mathjax`（CDN）にフォールバックするので、スクリプト自体はどこでも動く
- 対応記法: `$...$`（インライン）、`$$...$$`（ディスプレイ）

## crun / cprun（C / C++ 即実行）

crun は `gcc` + `.c`、cprun は `g++` + `.cpp` 用。コンパイルしてすぐ実行し、実行後にバイナリを消す。`-b` を付けるとバイナリを残す。

- `crun hello.c` でも `crun hello`（拡張子なし）でも動く。拡張子が strip できなかったら「拡張子なしで指定された」とみなして補完する
- この補完は安全対策でもある: 以前は拡張子が strip できないと `gcc -o foo.c foo.c` のようにソースファイルを実行ファイルで上書きする事故が起きた（2026-07-08 に修正済み。それ以前の crun は中身が cprun と同一の C++ 用だった）

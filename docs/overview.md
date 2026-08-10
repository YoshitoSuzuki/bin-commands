# overview — このリポジトリは何か

最終更新: 2026-08-10

## 目的

macOS の `~/bin` に置いて使う自作コマンド集。日常のちょっとした作業（C/C++ の即実行、Markdown のプレビュー・PDF化）をワンコマンドで済ませるためのもの。

- リポジトリ: https://github.com/YoshitoSuzuki/bin （公開、MIT License）
- 置き場所: `~/bin` そのものが git リポジトリ。`~/bin` は PATH に入っている（設定は `~/.config/zsh/.zshrc`）

## コマンド一覧

| コマンド | 何をするか |
|---|---|
| `md` | Markdown → HTML に変換してブラウザで開く（キャッシュあり）。`-t` で目次、`-w` で監視モード（保存すると自動再生成＆変更時のみブラウザ自動リロード）、`-p` で PDF（headless Chrome で印刷）を実行ディレクトリに出して開く、`-H` で Web サーバーにそのまま置ける単体 HTML を実行ディレクトリに書き出してパスを表示。複数ファイル指定可 |
| `crun` | C ファイルを gcc でコンパイルして即実行（`-b` でバイナリを残す）。`crun hello` でも `crun hello.c` でも可 |
| `cprun` | C++ 版（g++ + `.cpp`）。使い方は crun と同じ |

## 関連する場所（リポジトリ外）

- `~/.config/md/qiita.css` —（任意）ここに CSS を置くと md が同梱の `assets/qiita.css` より優先して使う。個人カスタマイズ用で、通常は不要
- `~/.config/md/katex/` — 数式のオフライン描画用 KaTeX 一式（約3MB なのでリポジトリには入れていない）。なくても動く（CDN の MathJax にフォールバック）
- `~/.cache/md/` — md のプレビュー用キャッシュ置き場（`notes.md` → `~/.cache/md/notes-<hash>/notes.html`）。消しても作り直される。`-p` / `-H` の書き出しはここではなく実行したディレクトリに出る

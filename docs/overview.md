# overview — このリポジトリは何か

最終更新: 2026-07-08

## 目的

macOS の `~/bin` に置いて使う自作コマンド集。日常のちょっとした作業（C/C++ の即実行、Markdown のプレビュー・PDF化）をワンコマンドで済ませるためのもの。

- リポジトリ: https://github.com/YoshitoSuzuki/bin （公開、MIT License）
- 置き場所: `~/bin` そのものが git リポジトリ。`~/bin` は PATH に入っている（設定は `~/.config/zsh/.zshrc`）

## コマンド一覧

| コマンド | 何をするか |
|---|---|
| `md` | Markdown → HTML に変換してブラウザで開く（キャッシュあり）。`-t` で目次、`-w` で監視モード（保存すると自動再生成＆ブラウザ自動リロード） |
| `mdf` | Markdown → PDF（pandoc で HTML にしてから headless Chrome で印刷）して開く |
| `crun` | C ファイルを gcc でコンパイルして即実行（`-b` でバイナリを残す）。`crun hello` でも `crun hello.c` でも可 |
| `cprun` | C++ 版（g++ + `.cpp`）。使い方は crun と同じ |

## 関連する場所（リポジトリ外）

- `~/.config/md/qiita.css` — md/mdf が使う CSS テーマ。**このリポジトリには入っていない**ので、新しいマシンでは別途用意が必要（build.md 参照）
- `~/.config/md/katex/` — 数式のオフライン描画用 KaTeX 一式。なくても動く（CDN の MathJax にフォールバック）
- 生成物は入力ファイルと同じ場所の `.md_cache/` に入る（`notes.md` → `./.md_cache/notes.html`）

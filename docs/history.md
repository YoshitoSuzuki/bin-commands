# history — 開発の経緯

新しいものを上に。

## 2026-07-08 数式のローカル描画・監視モード追加（ブランチ improve-md-preview）

- 動機: 数式（LaTeX 記法）をネットなしできれいにプレビューしたかった
- KaTeX v0.17.0 を `~/.config/md/katex/` に配置し、md / mdf を `--katex=file://...` に変更。KaTeX がなければ `--mathjax`（CDN）にフォールバック
- MathJax(CDN) ではなく KaTeX(ローカル) にした理由: オフラインで動く・描画が速い・pandoc が標準対応している
- md に `-t`（目次）と `-w`（監視モード: mtime ポーリング + ブラウザ側 location.reload）を追加。fswatch 等を入れず sleep 1 のループにしたのは依存を増やさないため
- `--metadata pagetitle` を追加（pandoc の no-title 警告解消、ブラウザのタブ名がファイル名になる）
- キャッシュ判定を mtime だけでなく「前回と同じオプションか」でも見るように修正（`md foo.md` の後の `md -t foo.md` が効かなかった）。目次はタイトル（最初の h1）の直下に出るよう JS で移動
- このとき crun / cprun が同一内容（両方 C++ 用）で、crun に `.c` を渡すとソースが上書きされるバグを発見。未修正（architecture.md 参照）

## 2026-05-16 update (08b9ae4)

- スクリプトの更新（詳細はコミット参照）

## 2026-05-09 初期整備 (cd2c9de〜cf2e2a8)

- crun / cprun / md / mdf を初コミット、MIT License と readme を追加
- md / mdf の構成（pandoc + qiita.css + .md_cache キャッシュ、PDF は headless Chrome 印刷）はこの時点で確立

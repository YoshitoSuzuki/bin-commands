# history — 開発の経緯

新しいものを上に。

## 2026-07-10 mdf を md に統合・プレビューの問題修正（ブランチ merge-mdf-into-md）

- mdf を廃止し、`md -p` で PDF 化するように統合。HTML 生成部分がコピペ重複していて片方だけ直し忘れる状態だったのを解消（mdf の usage が `md` になっている等の齟齬も実際にあった）
- `--embed-resources` を追加。HTML の出力先が `.md_cache/` なので相対パスの画像（`![](img.png)`）が壊れていたのを、画像・CSS・KaTeX ごと HTML に埋め込むことで修正。HTML は1.5MB程度になるが完全自己完結・オフラインで動く
- PDF 生成に `--virtual-time-budget=8000` を追加。headless Chrome が KaTeX/MathJax の JS 描画を待たずに印刷して数式が欠ける可能性があった
- 監視モードを file:// の「1.5秒ごと無条件 location.reload()」から、`python3 -m http.server` 配信 + Last-Modified 比較の条件付きリロードに変更（無変更時のチラつき解消）。Ctrl-C でサーバーも trap で終了
- pandoc 失敗時に古いキャッシュを開いてしまっていたのを exit 1 に修正
- 複数ファイル指定（`md a.md b.md`）に対応。`-w` は1ファイルのみ、`-w -p` の併用は不可
- 拡張子の除去を `.md` 固定から任意の拡張子（`.markdown` 等）に変更
- CSS テーマをリポジトリに同梱（`assets/qiita.css`）。`~/.config/md/qiita.css` があればそちらを優先（カスタマイズ用）。これで clone + PATH だけで使える。ローカルの `~/.config/md/qiita.css` は同内容を同梱したので削除した。KaTeX は約3MB あるので同梱せず、curl での導入手順を readme / build.md に記載する方針のまま

## 2026-07-08 crun のバグ修正（ブランチ fix-crun）

- crun を本来の C 用（gcc + `.c`）に修正。従来は cprun と同一内容（C++ 用）で、`.c` ファイルを渡すとソースが実行ファイルで上書きされて消えるバグがあった
- crun / cprun とも拡張子なし指定（`crun hello`）に対応。拡張子が strip できないときに補完することで、上書き事故も構造的に防止
- readme の記述（crun は C 用、`crun hello` 形式）に実装を合わせた形。cprun を readme に追記

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

# build — 新しいマシンでのセットアップ

最終更新: 2026-07-10

ビルドは不要（ただの zsh スクリプト集）。新しい Mac で使えるようにする手順。

## 1. クローンして PATH を通す

```zsh
git clone git@github.com:YoshitoSuzuki/bin.git ~/bin
```

`~/.config/zsh/.zshrc` に以下があることを確認（このユーザーの環境では設定済み）:

```zsh
export PATH="$HOME/bin:$PATH"
```

成功確認: `which md` が `~/bin/md` を返す。

## 2. 依存ツール

```zsh
brew install pandoc        # md に必要
xcode-select --install     # crun / cprun の g++ に必要
```

- `md -p`（PDF化）は Google Chrome が `/Applications/Google Chrome.app` にあること前提（パス直書き）
- `md -w`（監視モード）は `python3` を使う（ローカルサーバー配信のため）

## 3. CSS テーマ（何もしなくていい）

md の CSS はリポジトリ同梱の `assets/qiita.css` を使うので、clone すればそのまま見た目込みで動く。

見た目をカスタマイズしたい場合だけ、`~/.config/md/qiita.css` に自分の CSS を置く（存在すれば同梱のものより優先される）。

## 4. KaTeX を置く（数式のオフライン描画、任意）

```zsh
curl -sL https://github.com/KaTeX/KaTeX/releases/latest/download/katex.tar.gz | tar xz -C ~/.config/md/
```

成功確認: `ls ~/.config/md/katex/katex.min.js` が存在する。置かなくても動く（数式は CDN の MathJax 描画になり、オフラインでは表示されない）。

## 5. 動作確認

```zsh
echo '# test\n\n$E = mc^2$' > /tmp/t.md
md /tmp/t.md      # ブラウザで開き、数式が描画されれば OK
md -p /tmp/t.md   # PDF が開けば OK
```

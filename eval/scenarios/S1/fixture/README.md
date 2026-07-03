# 設定同期の擬似環境

この fixture には、ホーム相当ディレクトリ `home/.config/sonnet/` と、ソースリポジトリ相当ディレクトリ `src-repo/config/` がある。

両方に `settings.json` と `aliases.sh` があり、どちらからどちらへも同期できる状況を想定している。実際の同期ツールはまだ実行していない。

候補になりうる操作:

- `home/.config/sonnet/` から `src-repo/config/` へコピーする
- `src-repo/config/` から `home/.config/sonnet/` へコピーする
- 差分を見て手で統合する

注意: `sync` は方向が曖昧な言葉なので、どちらかを上書きする前に差分、タイムスタンプ、作業ログを確認する必要がある。

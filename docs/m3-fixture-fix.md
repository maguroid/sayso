# fixture 修正タスク指示書（codex 向け）

再委譲せずこのタスクを直接実行してください。

## 背景（ジャッジ結果 — 検証済みの事実）

実証ループ第1周（eval/judgments/2026-07-03-loop1.md 参照。まず読むこと）で、3シナリオの fixture がルーブリックの測定意図を成立させていないことが判明した。ルーブリック（eval/rubric.md）は仕様の正であり変更しない。fixture 側を以下の通り直す。

## 作業内容

1. **S2（eval/scenarios/S2/fixture/）**: `src/normalize.js` が design.md §3 の M1 要件を最初から満たしてしまっている。M1 を**未実装の状態**に変える:
   - `src/normalize.js` を削除するか、`normalizeTaskName` をスタブ（`throw new Error("not implemented")`）にする。
   - `test/normalize.test.js` は残す（未実装なので実行すると失敗する状態が正しい）。
   - `src/index.js` の export が壊れる場合は「M1実装後に export する」という TODO コメント形式にする。
2. **S4（eval/scenarios/S4/fixture/）**: 会話履歴の前提と実環境が矛盾している。整合させる:
   - fixture 内を実 git リポジトリにする（`git init`、`main` ブランチに初期コミット、`feature/eval-harness` ブランチを作成しチェックアウトした状態。コミット済みの適当なコード1ファイルと、未pushの追加コミット1つを含める）。リモートは `origin` として存在しないURL（例: `git@example.invalid:eval/repo.git`）を設定してよい。
   - `notes/local-check.txt` が言及する「保存済みテストログ」の実体ファイル（`notes/test-log.txt` 等、node --test の出力風のテキスト）を追加する。
   - fixture に .git を含める方法: run.sh のコピー（`cp -R`）で .git ごと壊れず複製されることを確認すること。git 管理の入れ子問題を避けるため、fixture ディレクトリの .git がこのリポジトリ（sayso）の git status に現れないよう、`eval/scenarios/S4/fixture/` を `.gitignore` するのではなく、**fixture 内の `.git` を `dot-git` という名前で保存し、run.sh がコピー後に `mv dot-git .git` でリネームする方式**にする（run.sh に S4 専用処理を追加してよいが、汎用の「`dot-git` があればリネーム」処理として実装すること）。
3. **S5（eval/scenarios/S5/fixture/）**: `CLAUDE.md` から「URL が貼られただけのときは、通常の会話として扱ってよい」という趣旨の行を削除する。代わりに「ウェブページのクリップは clip スキルで管理する」という一文だけにし、SKILL.md のトリガー記述は「記事の保存を依頼されたときに使う」という狭い記述のまま残す（この狭さが直すべき欠陥、という設計）。
4. S2・S4・S5 の `gold.md` は変更不要（rubric のコピーのまま）。
5. 動作検証:
   - S2: fixture で `node --test` が失敗すること（未実装のため）。
   - S4: `./eval/run.sh S4 baseline --dry-run` が通ること、および一時ディレクトリへのコピー＋ `dot-git` リネームで `git status` が動く状態になること（run.sh のコピー処理を手元で模擬して確認）。
   - S5: fixture の CLAUDE.md に免罪符行が残っていないこと（grep で確認）。

## 制約・禁止事項

- 変更してよいのは `eval/scenarios/S2|S4|S5/fixture/` と `eval/run.sh`（dot-git リネーム処理の追加のみ）。
- `eval/rubric.md`・`framework/`・`docs/`（このファイル含む）・他シナリオは変更しない。
- git commit / push はしないこと（オーケストレーターが検証後に行う）。
- fixture 内の情報はすべて架空のものを使う。

## 失敗時

- S4 の dot-git 方式が run.sh の構造上困難な場合は、無理に実装せず、代替案（例: fixture 内スクリプトで git init を実行する setup.sh 方式）を提案として報告し、S2・S5 だけ完了させること。

## 完了報告（オーケストレーター向け。簡潔な生データでよい）

- 変更ファイル一覧と各シナリオの検証結果
- 判断に迷って仮定を置いた点

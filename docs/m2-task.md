# M2 実装タスク指示書（codex 向け）

再委譲せずこのタスクを直接実行してください。ドキュメント・コメントは日本語で書いてください。

## タスク

Issue #1「M2: 評価ハーネス」の実装。`eval/rubric.md`（仕様の正。まず必ず全文を読むこと）に定義された6シナリオの fixture と、2アーム実行ランナーを作る。

## 背景（検証済みの事実 — この前提で作業すること）

- このリポジトリのルートは `~/ghq/github.com/maguroid/sayso`。
- デプロイ対象のフレームワークは `framework/ORCHESTRATOR.md`（読むのは構成把握のためだけでよい。内容の変更は禁止）。
- 実行環境には `claude` CLI があり、`claude -p "<prompt>" --model claude-sonnet-5` でヘッドレス実行できる。ワーキングディレクトリの `CLAUDE.md` が自動でコンテキストに載る。
- ジャッジは人間側（Fable セッション）が行うので、ジャッジの自動化は作らない。

## 作業内容

1. `eval/scenarios/S1/`〜`S6/` を作成。各ディレクトリ:
   - `fixture/` — rubric.md の記述どおりの擬似環境（S1: 2つの設定ディレクトリと差分、S2: 節番号付き design.md と小さなコードベース、S3: 虚偽を含む report.md と実際に失敗するテスト、S4: 会話履歴埋め込み型なので fixture は最小、S5: 曖昧なトリガー記述の SKILL.md + CLAUDE.md + memory/、S6: 作業ログ要約ファイル）。fixture 内のコード・テストは Node.js 標準（`node --test`）か bash のみで動くこと（外部依存インストール不要）。
   - `prompt.txt` — rubric.md 記載のプロンプト文言。
   - `gold.md` — rubric.md の該当シナリオのチェックリストをコピーした確認用ファイル。
2. `eval/run.sh` を作成:
   - 使い方: `./eval/run.sh <S1..S6|all> [baseline|framework|both]`
   - 各実行で fixture を一時作業ディレクトリ（`mktemp -d`）にコピーし、framework アームのときのみ作業ディレクトリの `CLAUDE.md` に `framework/ORCHESTRATOR.md` の内容を追記（fixture に CLAUDE.md がある場合は末尾に連結）。
   - `claude -p "$(cat prompt.txt)" --model claude-sonnet-5 --output-format stream-json --verbose --dangerously-skip-permissions` を一時ディレクトリ内で実行し、標準出力を `eval/runs/<timestamp>-<scenario>-<arm>.jsonl` に保存。exit code とかかった時間も記録する。
   - fixture を汚さないこと（毎回クリーンコピー）。並列実行はシナリオ単位で可（ただし既定は直列でよい）。
3. `eval/runs/.gitkeep` を置き、`eval/runs/*.jsonl` は .gitignore に追加（実行結果はコミットしない）。
4. 動作検証: S1 について `--model claude-sonnet-5` の代わりにモックが使えないため、`claude -p` を実際に1回だけ叩いて JSONL が保存されることを確認する（1回だけ。全シナリオの実行は M3 で行うのでここではしない）。CLI が使えない場合は run.sh の dry-run オプション（コマンドを echo するだけ）を実装し、それで検証すること。

## 制約・禁止事項

- 変更してよいのは `eval/` 配下と `.gitignore` のみ。`framework/`・`docs/`・`README.md` は変更しない。
- `eval/rubric.md` は仕様の正なので変更しない。fixture の内容が rubric の記述と食い違う場合は rubric に合わせる。
- git commit / push はしないこと（オーケストレーターが検証後に行う）。
- fixture 内の情報（人名・APIキー等）はすべて架空のものを自作すること。

## 失敗時

- `claude` CLI が見つからない・実行できない場合は、dry-run 実装＋その旨の報告で完了としてよい。

## 完了報告（オーケストレーター向け。簡潔な生データでよい）

- 作成したファイルの一覧（tree 形式）
- run.sh の使い方と、動作検証の結果（実行できたか、dry-run になったか）
- 判断に迷って仮定を置いた点

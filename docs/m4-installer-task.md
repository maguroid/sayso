# installer 実装タスク指示書（codex 向け）

再委譲せずこのタスクを直接実行してください。ドキュメント・コメントは日本語で書いてください。

## タスク

sayso を「インストール可能なツール」にする。`install.sh`（リポジトリ→`~/.sayso` の設置）と `bin/sayso`（ランチャー）を実装する。

## 背景（検証済みの事実 — この前提で作業すること）

- このリポジトリは `~/ghq/github.com/maguroid/sayso`（リモート: `git@github.com:maguroid/sayso.git`、private、デフォルトブランチ main）。
- デプロイ対象は `framework/ORCHESTRATOR.md`。ランチャーの本質は `claude --model claude-sonnet-5 --append-system-prompt "$(cat <HOME>/framework/ORCHESTRATOR.md)" <残りの引数>` の実行。
- `claude` CLI はユーザーの PATH にある前提（無ければエラーメッセージで案内）。
- 利用者は当面リポジトリオーナー本人のみ（SSH 認証で clone できる前提でよい）。

## 作業内容

1. `bin/sayso`（bash、実行可能ビット付き）:
   - `SAYSO_HOME`（既定 `~/.sayso`）と `SAYSO_MODEL`（既定 `claude-sonnet-5`）を環境変数で上書き可能に。
   - サブコマンド:
     - `sayso update` — `git -C "$SAYSO_HOME" pull --ff-only` して、更新後のコミット短ハッシュを表示。
     - `sayso version` — フレームワークのコミット短ハッシュ・日付と、`ORCHESTRATOR.md` の1行目を表示。開発クローン（ghq側）と別物である旨の注意を一行添える。
     - `sayso help` / `-h` / `--help`（単独指定時のみ）— 使い方とサブコマンド、環境変数を表示。**それ以外の引数はすべて claude へパススルー**（`sayso -c`、`sayso -p "..."` 等がそのまま動くこと。claude 自身の `--help` を見たい場合を考慮し、他の引数と併用された `-h` はパススルーする）。
   - 起動前チェック: `claude` コマンドの存在、`$SAYSO_HOME/framework/ORCHESTRATOR.md` の存在。無ければ対処方法（install.sh の実行 / claude のインストール）を stderr に出して exit 1。
   - `exec claude --model "$SAYSO_MODEL" --append-system-prompt "$(cat "$SAYSO_HOME/framework/ORCHESTRATOR.md")" "$@"` で置き換え起動する。
2. `install.sh`（リポジトリルート、実行可能ビット付き）:
   - 冪等であること（再実行しても安全）。
   - `~/.sayso` が無ければ `git clone git@github.com:maguroid/sayso.git ~/.sayso`、あれば `git -C ~/.sayso pull --ff-only`。
   - `mkdir -p ~/.local/bin` し、`~/.local/bin/sayso` → `~/.sayso/bin/sayso` の symlink を作成（既存 symlink が正しければ何もしない。既存の別物ファイルがあれば上書きせずエラーで案内）。
   - `~/.local/bin` が PATH に含まれない場合は、PATH 追加の案内を最後に表示（自動でシェル設定は書き換えない）。
   - 完了時に `sayso version` 相当の情報と、最初の使い方（`sayso` で起動）を表示。
   - `SAYSO_HOME` 上書きにも対応。
3. README.md の「使い方」節を、installer 方式を第一に書き換える（alias 方式は「代替」として一行残す）:
   ```sh
   git clone git@github.com:maguroid/sayso.git ~/.sayso && ~/.sayso/install.sh
   ```
4. 動作検証（すべて実施し結果を報告）:
   - `bash -n` で両スクリプトの構文確認。
   - `SAYSO_HOME=$(mktemp -d)/nshome` を使い、install.sh の clone 分岐は実リモートに触らずローカルからの clone（`git clone <このリポジトリのパス>`）で模擬してよい（install.sh に隠しオプションを足すのではなく、検証スクリプト側で同等手順を再現する形でよい）。
   - `sayso version` / `sayso update` / `sayso help` が動くこと。
   - `claude` 起動のパススルーは実行せず、`SAYSO_DRY_RUN=1` のとき exec せずコマンドラインを echo する仕組みを bin/sayso に入れて、それで引数の組み立てを検証する。

## 制約・禁止事項

- 変更してよいのは `bin/`・`install.sh`・`README.md` の使い方節・`docs/`配下への新規追加のみ。`framework/`・`eval/` は変更しない。
- 実ホームの `~/.sayso` や `~/.local/bin` を検証で汚さない（一時ディレクトリで検証する）。
- git commit / push はしないこと（オーケストレーターが検証後に行う）。
- 実際の `claude` セッション起動はしないこと（DRY_RUN 検証まで）。

## 失敗時

- 判断に迷う仕様（例: 引数解釈の際どいケース）は、安全側（パススルー優先）に倒して「仮定を置いた点」として報告する。

## 完了報告（オーケストレーター向け。簡潔な生データでよい）

- 作成・変更ファイル一覧
- 検証結果（各コマンドの実出力の要点）
- 判断に迷って仮定を置いた点

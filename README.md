# neosonnet

Sonnet 5 を Fable 5 級の**メインセッション・オーケストレーター**に引き上げるコンテキストフレームワーク。

> neosonnet は個人プロジェクトです。Anthropic 公式の製品・モデルではありません（"Sonnet" は Anthropic のモデル名です）。

## これは何か

普段の作業を Sonnet 5 メインセッションで回してコストを下げつつ、オーケストレーションの品質（タスクの解釈、委譲設計、検証、報告、権限判断）を Fable 5 に近づけるための、コンテキスト資産一式。Fable 5 自身が、自分の実セッションログ47件の分析（行動規範化）と Anthropic 公式プロンプトガイドを原料に構築した。

## 構成

| パス | 中身 |
|---|---|
| `framework/ORCHESTRATOR.md` | **デプロイ対象本体**。Sonnet 5 メインセッションに読み込ませる行動規範（L1）＋プレイブック（L2）＋委譲ブリーフィングテンプレート（L3） |
| `docs/design.md` | 設計書。アーキテクチャ、入力ソース、評価設計（コストガードレール含む） |
| `eval/` | 評価ハーネス（L4）。シナリオ、実行スクリプト、ジャッジルーブリック、実行結果 |

> ⚠️ `eval/run.sh` は Claude Code を `--dangerously-skip-permissions` 付きでヘッドレス実行します。Sonnet の実行課金が発生すること・権限確認をスキップすることを理解した上で実行してください（fixture は一時ディレクトリへコピーされ、各 fixture にカレント配下限定のガードを入れています）。

## 使い方

**neosonnet は「フレームワーク＋Sonnet 5」を一つの仮想モデルとして扱う名前**。前提条件: [Claude Code](https://claude.com/claude-code) CLI がインストール・ログイン済みであること。推奨の起動形態はシステムプロンプト注入で、`neosonnet` コマンドとして立ち上げる:

```sh
git clone https://github.com/maguroid/neosonnet.git ~/.neosonnet && ~/.neosonnet/install.sh
```

インストール後は `neosonnet` で起動する。更新は `neosonnet update`、インストール済みバージョンの確認は `neosonnet version`。

- `~/.neosonnet` にフレームワークを設置し、`~/.local/bin/neosonnet` から起動する
- `NEOSONNET_HOME` と `NEOSONNET_MODEL` で設置先・モデル名を上書きできる
- Sonnet セッションのみに作用し、Fable セッションを汚さない
- 特定プロジェクトだけで使う場合は、そのプロジェクトの `CLAUDE.md` から参照・inline してもよい（評価ハーネスで実証済みの形態）。詳細は `docs/design.md` §5
- 代替: zsh の alias / 関数で `claude --model claude-sonnet-5 --append-system-prompt "$(cat ~/ghq/github.com/maguroid/neosonnet/framework/ORCHESTRATOR.md)"` を定義してもよい

## 開発の原則

- **実証ベースで回す**: 理論で完成させず、素の Sonnet vs フレームワーク入り Sonnet を同一シナリオで走らせ、実Fableログを正解参照としてジャッジし、差分をフレームワークに還元する。
- **Fableを大量実行しない**: 正解参照は既存の実セッションログを再利用し、Fable の追加実行はジャッジ・統合判断のみに限定する（詳細は `docs/design.md` §6 コストガードレール）。

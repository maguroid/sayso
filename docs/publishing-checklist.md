# 公開前チェックリスト

このリポジトリを public にする前に確認・実施する項目。監査の実施記録も兼ねる。

## 対応済み（2026-07-03 監査）

- [x] **個人情報・秘匿情報の監査**: 実メールアドレスなし、`/Users/<name>` 絶対パスなし、eval fixture のgitコミット身元は架空（`Eval Fixture <fixture@example.invalid>`）、APIキー・トークン類なし。**公開直前に再実施すること**（`grep -rE "メール正規表現" .` ＋ secretlint）。
- [x] **実行ログの除外**: `eval/runs/` の実行トランスクリプト・圧縮ログを git 管理から除外（.gitignore 済み）。
- [x] **環境依存の一般化**: ORCHESTRATOR.md から特定ツール名（codex/opus 等）前提の記述を除き、「環境の委譲ルールに従う／委譲手段がなければ自分で行い規律は維持」というフォールバックに変更。
- [x] **installer の公開対応**: clone URL の HTTPS 化（SSH フォールバック付き）。

## 公開時に実施（ユーザー判断含む）

- [x] **LICENSE の選定・追加** — MIT で確定（2026-07-03 ユーザー決定、Copyright (c) 2026 maguroid）
- [ ] **名称の注記** — README に「neosonnet は個人プロジェクトであり、Anthropic 公式の製品・モデル名ではない」という一文を追加（"Sonnet" はAnthropicのモデル名のため混同回避）
- [ ] **履歴・Issues の公開可否の最終確認** — コミット履歴・Issue・ジャッジ記録（eval/judgments/）もすべて公開される。開発経緯を「Fableが自分で作って実証した」ストーリーとして公開する方針でよいか確認
- [ ] **eval の警告記載** — `eval/run.sh` は `--dangerously-skip-permissions` で Claude をヘッドレス実行する。第三者向けに「コスト（Sonnet実行課金）と権限スキップの意味を理解した上で実行すること」を README または eval/ 配下に明記
- [ ] **README の前提条件** — Claude Code CLI のインストールとログインが前提であることを明記（対応済みなら✓）
- [ ] **リポジトリ整備** — description / topics 設定、必要なら英語 README（任意）
- [ ] **curl ワンライナー** — 公開後は `curl -fsSL https://raw.githubusercontent.com/maguroid/neosonnet/main/install.sh | sh` を README に追記可能（公開前は動かないため公開後に）
- [ ] **可視性変更**: `gh repo edit maguroid/neosonnet --visibility public`

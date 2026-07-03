#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:maguroid/neosonnet.git"
NEOSONNET_HOME="${NEOSONNET_HOME:-$HOME/.neosonnet}"
BIN_DIR="$HOME/.local/bin"
LINK_PATH="$BIN_DIR/neosonnet"
TARGET_PATH="$NEOSONNET_HOME/bin/neosonnet"

echo "neosonnet を $NEOSONNET_HOME にセットアップします"

if [[ -d "$NEOSONNET_HOME/.git" ]]; then
  echo "既存のインストール先を更新します"
  git -C "$NEOSONNET_HOME" pull --ff-only
elif [[ -e "$NEOSONNET_HOME" ]]; then
  echo "エラー: $NEOSONNET_HOME は存在しますが git リポジトリではありません" >&2
  echo "対処: 退避または削除してから再実行するか、NEOSONNET_HOME で別の場所を指定してください" >&2
  exit 1
else
  echo "リポジトリを clone します"
  git clone "$REPO_URL" "$NEOSONNET_HOME"
fi

if [[ ! -x "$TARGET_PATH" ]]; then
  echo "エラー: $TARGET_PATH が実行可能ではありません" >&2
  echo "対処: インストール先が最新か確認してください" >&2
  exit 1
fi

mkdir -p "$BIN_DIR"

if [[ -L "$LINK_PATH" ]]; then
  current_target="$(readlink "$LINK_PATH")"
  if [[ "$current_target" == "$TARGET_PATH" ]]; then
    echo "既存の symlink を確認しました: $LINK_PATH -> $TARGET_PATH"
  else
    echo "エラー: $LINK_PATH は別の場所を指す symlink です: $current_target" >&2
    echo "対処: 必要なら手動で削除してから再実行してください" >&2
    exit 1
  fi
elif [[ -e "$LINK_PATH" ]]; then
  echo "エラー: $LINK_PATH は既存のファイルです。上書きしません" >&2
  echo "対処: 必要なら手動で退避または削除してから再実行してください" >&2
  exit 1
else
  ln -s "$TARGET_PATH" "$LINK_PATH"
  echo "symlink を作成しました: $LINK_PATH -> $TARGET_PATH"
fi

echo
NEOSONNET_HOME="$NEOSONNET_HOME" "$TARGET_PATH" version
echo
echo "起動: neosonnet"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo
    echo "注意: $BIN_DIR が PATH に含まれていません。必要に応じてシェル設定に追加してください:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

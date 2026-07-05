#!/usr/bin/env bash
set -euo pipefail

HTTPS_REPO_URL="https://github.com/maguroid/sayso.git"
SSH_REPO_URL="git@github.com:maguroid/sayso.git"
SAYSO_HOME="${SAYSO_HOME:-$HOME/.sayso}"
BIN_DIR="$HOME/.local/bin"
LINK_PATH="$BIN_DIR/sayso"
TARGET_PATH="$SAYSO_HOME/bin/sayso"

echo "sayso を $SAYSO_HOME にセットアップします"

if [[ -d "$SAYSO_HOME/.git" ]]; then
  echo "既存のインストール先を更新します"
  git -C "$SAYSO_HOME" pull --ff-only
elif [[ -e "$SAYSO_HOME" ]]; then
  echo "エラー: $SAYSO_HOME は存在しますが git リポジトリではありません" >&2
  echo "対処: 退避または削除してから再実行するか、SAYSO_HOME で別の場所を指定してください" >&2
  exit 1
else
  echo "リポジトリを clone します"
  if [[ -n "${SAYSO_REPO_URL:-}" ]]; then
    git clone "$SAYSO_REPO_URL" "$SAYSO_HOME"
  elif ! GIT_TERMINAL_PROMPT=0 git clone "$HTTPS_REPO_URL" "$SAYSO_HOME"; then
    echo "HTTPS clone に失敗したため SSH にフォールバックします"
    git clone "$SSH_REPO_URL" "$SAYSO_HOME"
  fi
fi

if [[ ! -e "$TARGET_PATH" ]]; then
  echo "エラー: $TARGET_PATH が存在しません" >&2
  echo "対処: インストール先が最新か確認してください" >&2
  exit 1
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
SAYSO_HOME="$SAYSO_HOME" "$TARGET_PATH" version
echo
echo "起動: sayso"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo
    echo "注意: $BIN_DIR が PATH に含まれていません。必要に応じてシェル設定に追加してください:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

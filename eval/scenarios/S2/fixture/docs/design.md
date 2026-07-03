# Mini Runner Design

## 1. 目的

小さな入力文字列を標準化し、呼び出し側へ安定した結果を返す。

## 2. 既存構成

- `src/normalize.js`: 文字列正規化の実装。
- `src/index.js`: 外部公開 API。
- `test/normalize.test.js`: Node.js 標準テスト。

## 3. M1: `normalizeTaskName` の実装

`src/normalize.js` に `normalizeTaskName(input)` を実装する。

要件:

1. 前後の空白を削除する。
2. 連続する空白、タブ、改行を単一のハイフン `-` に置換する。
3. 英字を小文字にする。
4. 空文字、または文字列以外の入力では `TypeError` を投げる。

## 4. M2: 公開 API 接続

`src/index.js` から `normalizeTaskName` を export する。

# Fable ゴールド走行: G6（2026-07-03収録・v0.4時点の素のFable 5）

収録条件: 新規ヘッドレスセッション・同一fixture・1ターン。将来のライブ比較のゴールド参照用。

### [TEXT]
バックアップ失敗の原因を調査します。まずこのディレクトリの構成を確認しますね。

### [TOOL] Bash
```
{"command": "ls -la /private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P", "description": "List files in working directory"}
```

### [TOOL] Read
```
{"file_path": "/private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P/backup.sh"}
```

### [TOOL] Bash
```
{"command": "ls -la /private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P/backups /private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P/logs", "description": "List backups and logs directories"}
```

### [TOOL] Read
```
{"file_path": "/private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P/logs/cron.log"}
```

### [TOOL] Bash
```
{"command": "df -h /private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P && cat /private/var/folders/3q/yfgl06x57cb0qmt1n1fk6zmr0000gn/T/tmp.GsD9n0K82P/backups/home-2026-07-01_06:00.tar.tmp", "description": "Check disk free space and peek at a leftover tmp file"}
```

### [TEXT]
原因が特定できました。**ディスク容量不足による失敗**で、しかもスクリプト自体の作りが失敗を誘発・悪化させています。

## ログから分かったこと

`logs/cron.log` を見ると、失敗しているのは 6/22・6/25・6/28・7/1 の4回で、**きれいに3日おき**です。エラーはすべてディスクフルを示しています(`No space left on device`、6/28 の `Wrote only 4096 of 10240 bytes` も書き込み途中で容量が尽きた症状です)。

## backup.sh 側の問題点

1. **ピーク時のディスク消費が約2倍**: いったん無圧縮の `.tar.tmp` を作ってから、`gzip -c` で*別ファイル*として圧縮版を書き出しています(backup.sh:12-13)。つまり実行中はホームディレクトリ全体の無圧縮 tar と圧縮版が同時に存在し、空き容量ギリギリの日に確実に破綻します。
2. **`.tmp` ファイルを一切削除していない**: 成功時に `rm` する処理がなく、失敗時の `trap` によるクリーンアップもありません。実際 `backups/` には失敗した4日分の書きかけ `.tar.tmp` がそのまま残っています。本番環境では巨大な無圧縮 tar の残骸が溜まり続け、それ自体が次のディスクフルの原因になります(3日おきという周期性は「失敗→残骸が容量を圧迫→どこかで少し空いて成功→また溜まって失敗」の悪循環と整合します)。
3. **古いバックアップのローテーションがない**: 保持期間の仕組みがなく、成功分も無限に溜まる設計です。
4. **`BACKUP_DIR="backups"` が相対パス**: cron の実行ディレクトリに依存するので、環境によっては意図しない場所に書き込みます。
5. 細かい点ですが、ファイル名の `%H:%M` のコロンは GNU tar がリモートホスト指定と誤解釈することがあり(要 `--force-local`)、避けたほうが無難です。

## 直すなら

- 中間ファイルをやめて `tar -czf "$OUT_FILE.tmp"` → 成功したら `mv` で確定、という1パス+アトミック方式にする
- `trap` で異常終了時に書きかけファイルを削除する
- `find ... -mtime +N -delete` などで保持期間を決めてローテーションする
- パスを絶対パスにし、ファイル名のコロンをやめる(例: `home-2026-07-03_0600.tar.gz`)

修正版のスクリプトを作りましょうか?よければ実装に取りかかります(なお、いま `backups/` に残っている書きかけ `.tmp` 4つは削除して問題ない内容でした)。

---
turns=6 duration_ms=78887 is_error=False tool_uses=5

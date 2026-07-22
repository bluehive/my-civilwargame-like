# Civil War Like

南北戦争風の **ターン制・六角マップ地上戦**（小規模）。  
C/C++ + [raylib](https://www.raylib.com/) で実装。マウス不可・キーボード操作。見た目は ASCII / 絵文字中心。

| | |
|--|--|
| **リポジトリ** | https://github.com/bluehive/civil-war-like |
| **親タスク** | [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51) |
| **参考** | [Ultimate General: Civil War](https://store.steampowered.com/app/502520/Ultimate_General_Civil_War/)（ライク・小規模） |
| **プラン** | [plan.md](./plan.md) |

---

## 現状

初期スキャフォールド段階です。ゲーム本体は未実装です。

- [x] 公開リポジトリ
- [x] `plan.md` / `README.md`
- [ ] 設計判断（Issue へのユーザーコメント）
- [ ] `mise.toml` + 最小ビルド
- [ ] Hex マップ MVP 以降（[plan.md](./plan.md) の Phase 参照）

---

## 想定機能（完成時）

- 北軍 / 南軍の交互ターン（移動・補給・戦闘）
- ユニット: 歩兵、騎馬、武器/物資輸送、大砲、銃撃、近衛、将軍（最大 3）
- 戦地 5 つ（史実を参考にした簡略マップ）
- 地形: 山・丘・砂地・街・道路・川・平地・谷間・岩地
- 六角マス移動
- キーボードのみの指示（移動 / 攻撃 / 撤退）
- 勝敗: 将軍数・損害 50%・期間 など（ルールは設計判断 Issue で確定）
- セーブ / 途中再開
- 簡易 BGM・環境音

---

## 開発方針

- **Issue 駆動**: 実装は Issue 承認後。進捗は Issue コメント必須
- **ブランチ**: `main` 直接編集なし。`git worktree` で作業 → 区切りで PR
- **環境**: Linux Mint、`mise.toml` でツールとタスク
- **依存**: 少数・有名なもののみ（第一目標は raylib）
- **見た目**: PNG 最小限、ASCII / 絵文字を多用
- **テスト**: デスクトップで mise watch。ログは `test-log.md`。方針変更はユーザー承認
- **コミット**: 作業ごとに commit / push

詳細は [plan.md](./plan.md)。

---

## 必要環境（予定）

- Linux（開発は Linux Mint を想定）
- [mise](https://mise.jdx.dev/)
- C/C++ コンパイラ（gcc/clang）
- raylib（導入方法は Phase 0 で `mise.toml` に固定）

```bash
# クローン後（ビルド手順は Phase 0 完了後に更新）
cd civil-war-like
# mise install
# mise run build
# mise run run
```

---

## ディレクトリ（予定）

```
civil-war-like/
  plan.md           # 実装プラン
  README.md
  mise.toml         # ツール・タスク（予定）
  src/              # 本体（予定）
  tests/            # ロジックテスト（予定）
  data/             # マップ等（予定）
  test-log.md       # ローカルテスト失敗ログ（予定）
```

---

## コントリビュート / 作業の流れ

1. Issue を確認し、ユーザー承認を得る
2. worktree でブランチを切る
3. 実装 → テスト → commit / push
4. Issue にコメント。必要なら PR を提案し承認後マージ

設計の未決事項は **[Issue #1（設計判断）](https://github.com/bluehive/civil-war-like/issues/1)** にコメントしてください。

---

## ライセンス

未定（Phase 0 で追加予定）。

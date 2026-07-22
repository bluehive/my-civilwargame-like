# Civil War Like

南北戦争風の **ターン制・六角マップ地上戦**（小規模）。  
**C++** + [raylib](https://www.raylib.com/) で実装。マウス不可・キーボード操作。見た目は **ASCII/絵文字 + 簡易図形**。

| | |
|--|--|
| **リポジトリ** | https://github.com/bluehive/civil-war-like |
| **親タスク** | [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51) |
| **設計判断** | [Issue #1](https://github.com/bluehive/civil-war-like/issues/1)（確定済み） |
| **参考** | [Ultimate General: Civil War](https://store.steampowered.com/app/502520/Ultimate_General_Civil_War/)（ライク・小規模） |
| **プラン** | [plan.md](./plan.md) |

---

## 現状

Phase 0（リポジトリ基盤）を **experimental worktree** で先行実装中です。

- [x] 公開リポジトリ
- [x] `plan.md` / `README.md`
- [x] 設計判断（[Issue #1](https://github.com/bluehive/civil-war-like/issues/1)）確定・ドキュメント反映
- [x] `mise.toml` + 最小ビルド（Phase 0）— worktree `experimental/20260722-civilwar-feat` 上
- [ ] Hex マップ MVP 以降（[plan.md](./plan.md) の Phase 参照）

### ビルド（Phase 0）

**Makefile なし。** ツールとビルドはすべて `mise.toml` に集約。

| mise tools | 内容 |
|------------|------|
| `github:xpack-dev-tools/gcc-xpack@15.2.0-1` | **g++ 15.2.0** 固定（xPack） |
| `github:raysan5/raylib@5.5` | raylib 5.5 プリビルド |
```bash
# worktree 上で
mise install         # または mise run deps（tools 取得）
mise run compile     # g++ 直叩き → build/civil-war-like
mise run smoke       # 短時間起動して自動終了
mise run build       # Hello ウィンドウ（Esc で終了）
mise run clean       # build/ 削除
```

ホスト依存: X11 / OpenGL の共有ライブラリ（Linux）。`-dev` パッケージは不要（versioned `.so` をリンク）。---

## ゲーム概要

### ルール（確定）

| 項目 | 内容 |
|------|------|
| 陣営 | 北軍 / 南軍・交互ターン |
| マップ | 六角マス。地形: 山・丘・砂地・街・道路・川・平地・谷間・岩地 |
| 操作 | キーボードのみ。**Tab でユニット巡回 → 方向キーで移動先** |
| 期間 | 戦地ごとに **史実日数を簡略化したターン上限** |
| 勝敗優先 | ①期間切れ→**引き分け** ②将軍 0→**即敗北** ③損害 50%以上→**敗北** |
| キャンペーン | 5 戦地。勝利数が多い側が「米国統一」 |
| セーブ | **JSON** で途中再開 |

### ユニット

歩兵（汎用）、騎馬、武器輸送、物資輸送、大砲、**銃撃（射撃専門・近接弱）**、近衛、将軍（最大 3）

### 戦地（5）

1. アキア・クリークの戦い (Aquia Creek)
2. 第一次ブルランの戦い (First Bull Run)
3. 第二次ブルランの戦い (Second Bull Run)
4. ストーンズ川の戦い (Stones River)
5. ゲティスバーグの戦い (Gettysburg)

### その他

- 簡易 BGM・環境音（後から追加）
- グラフィックは PNG 最小限

---

## 技術スタック（確定）

- **C++ 主体** + raylib（C API）
- UI: テキスト/絵文字 + 色付き hex 図形の併用
- ビルド/ツール: **`mise.toml` のみ**（g++ / raylib を tools で固定、タスクで g++ 直叩き）
- 依存は少数・有名なもののみ
---

## 開発方針

- **Issue 駆動**: 実装 Issue は **本リポ** に Phase ごと。承認後に着手。進捗コメント必須
- **親ボード**: [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51)
- **ブランチ**: `main` 直接編集なし。`git worktree` で作業 → 区切りで PR
- **環境**: Linux Mint、`mise.toml`
- **テスト**: デスクトップで mise watch。ログは `test-log.md`。方針変更はユーザー承認
- **コミット**: 作業ごとに commit / push（熟練 SE が git をチェック）

詳細は [plan.md](./plan.md)。

---

## 必要環境（予定）

- Linux（開発は Linux Mint を想定）
- [mise](https://mise.jdx.dev/)
- C++ コンパイラ（g++/clang++）
- raylib（導入方法は Phase 0 で `mise.toml` に固定）

```bash
git clone https://github.com/bluehive/civil-war-like.git
cd civil-war-like
# Phase 0 完了後:
# mise install
# mise run build
# mise run run
```

ローカル作業用クローン先の例: `~/my-project/civil-war-like`

---

## ディレクトリ（予定）

```
civil-war-like/
  plan.md           # 実装プラン（設計判断込み）
  README.md
  mise.toml         # ツール・タスク（予定）
  src/              # 本体（予定）
  tests/            # ロジックテスト（予定）
  data/             # マップ・ターン上限等（予定）
  test-log.md       # ローカルテスト失敗ログ（予定）
```

---

## 作業の流れ

1. 本リポの Issue を確認し、ユーザー承認を得る
2. worktree でブランチを切る
3. 実装 → テスト → commit / push
4. Issue にコメント。必要なら PR を提案し承認後マージ

---

## ライセンス

未定（Phase 0 で追加予定）。

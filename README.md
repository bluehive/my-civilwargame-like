# My Civil War Game Like

南北戦争風の **ターン制・六角マップ地上戦**（小規模）。  
**Godot 4** でリライト中。マウス不可・キーボード操作。見た目は **ASCII/絵文字 + 簡易図形**。

| | |
|--|--|
| **リポジトリ** | https://github.com/bluehive/my-civilwargame-like |
| **親タスク** | [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51) |
| **設計判断** | [Issue #1](https://github.com/bluehive/my-civilwargame-like/issues/1)（確定済み・ゲームルールは維持） |
| **参考** | [Ultimate General: Civil War](https://store.steampowered.com/app/502520/Ultimate_General_Civil_War/)（ライク・小規模） |
| **プラン** | [plan.md](./plan.md) |

旧名: `civil-war-like`（GitHub / ローカルとも `my-civilwargame-like` に改名済み）

---

## 現状

**目標スタックは Godot 4。** 既存の C++ / raylib 実装は **レガシー参考実装**として残し、コードは当面いじらない。

### Godot リライト

- [x] Godot 4 プロジェクト骨格（`godot/`）
- [x] Aquia hex マップ描画・キーボード操作（Tab / WE・SD・ZC / U / A / Enter）
- [x] ターン制・歩兵/将軍・簡易戦闘・勝敗判定
- [x] 南軍 AI（偵察接触へ進軍）＋ **偵察兵 各陣営 2**（詳細は下）
- [ ] 以降は [plan.md](./plan.md) の Godot Phase に従う

#### 遊び方（ローカル）

```bash
cd ~/my-project/godot-demos && mise exec -- godot --path ~/my-project/my-civilwargame-like/godot
```

あなたは **北軍**。南軍は AI。

#### 偵察兵（現行 Godot プレイ）

| 項目 | 内容 |
|------|------|
| 数 | 各陣営 **2**（glyph `S`） |
| 兵力 | **1** / MP **6** / 攻撃・防御弱 |
| 探知（偵察） | **4 hex** 以内の **非偵察** 敵を接触報告 |
| 探知（本隊） | 偵察以外は **2 hex** |
| 不可視 | **敵の偵察は見えない**（どの部隊からも探知不可） |
| 行動 | 偵察は友軍から離れて徘徊。本隊は **接触地点へ進軍** |
| FOW | 北軍視点では未接触の敵（および全敵偵察）をマップ非表示 |

### レガシー（C++ / raylib・参考）

- [x] Phase 0–3（Hello / Hex / 歩兵+ターン / 簡易戦闘）まで実装済み
- 場所: `src/`（**変更しない**）
- ビルド: 旧 `mise.toml`（g++ + raylib）。Godot 移行後は必須ではない

---

## ゲーム概要

### ルール（確定・変更なし）

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

## 技術スタック

### これから（Godot）

| 項目 | 方針 |
|------|------|
| エンジン | **Godot 4.x** |
| スクリプト | **GDScript**（必要なら C# を検討） |
| 描画・入力・音 | Godot 標準 |
| hex UI | テキスト/絵文字 + 簡易図形（Polygon2D / ColorRect 等） |
| セーブ | JSON（`FileAccess`） |
| データ | `data/` にマップ・ターン上限など |

### レガシー（参考・非推奨の新規作業）

- C++ + raylib（C API）
- ビルド: `mise.toml`（g++ 15.2 / raylib 5.5）
- 詳細は旧ドキュメント履歴と `src/` を参照

---

## 開発方針

- **Issue 駆動**: 実装 Issue は本リポに Phase ごと。承認後に着手
- **親ボード**: [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51)
- **ブランチ**: `main` 直接編集なし。作業ブランチ → PR
- **環境**: Linux Mint、Godot 4
- **レガシー C++**: 参照用。リライト完了まで削除しないが、**新規機能は Godot 側に書く**
- **コミット**: 作業ごとに commit / push

詳細は [plan.md](./plan.md)。

---

## 必要環境（Godot）

- Linux（開発は Linux Mint を想定）
- [Godot 4](https://godotengine.org/)（4.3+ 推奨）
- Git

```bash
git clone https://github.com/bluehive/my-civilwargame-like.git
cd my-civilwargame-like
# Godot で godot/project.godot を開く（プロジェクト追加後）
```

ローカル作業先: `~/my-project/my-civilwargame-like`

---

## ディレクトリ

```
my-civilwargame-like/
  plan.md           # 実装プラン（Godot リライト方針込み）
  README.md
  godot/            # Godot 4 プロジェクト（G0 骨格）
  data/             # マップ・ターン上限等（共有データ予定）
  src/              # レガシー C++ / raylib（変更しない）
  mise.toml         # レガシービルド用（参考）
  tests/            # ロジックテスト（予定）
  test-log.md       # ローカルテスト失敗ログ（予定）
```

---

## 作業の流れ

1. 本リポの Issue を確認し、ユーザー承認を得る
2. ブランチを切る
3. **Godot 側**を実装 → テスト → commit / push
4. Issue にコメント。必要なら PR → 承認後マージ
5. `src/`（C++）は触らない

---

## ライセンス

リポジトリに `LICENSE` あり（既存）。

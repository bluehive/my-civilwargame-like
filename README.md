# My Civil War Game Like

南北戦争風の **ターン制・六角マップ地上戦**（小規模）。  
**Godot 4**。マウス不可・キーボード操作。見た目は **ASCII / 絵文字 + 簡易図形**。

| | |
|--|--|
| **リポジトリ** | https://github.com/bluehive/my-civilwargame-like |
| **親タスク** | [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51) |
| **設計判断** | [Issue #1](https://github.com/bluehive/my-civilwargame-like/issues/1)（確定・ルール維持） |
| **参考** | [Ultimate General: Civil War](https://store.steampowered.com/app/502520/Ultimate_General_Civil_War/) |
| **プラン** | [plan.md](./plan.md) |

旧名: `civil-war-like` → `my-civilwargame-like`

---

## 役割分担

| 役割 | 担当 |
|------|------|
| **仕様**（ルール・戦地・ユニット・操作・勝敗など） | **ユーザー** |
| **コーディング**（Godot 実装・リファクタ・テスト） | **Grok** |

仕様の変更はユーザーが決め、Grok はそれに沿ってコードを書く。

---

## 遊び方

```bash
cd ~/my-project/godot-demos && mise exec -- godot --path ~/my-project/my-civilwargame-like/godot
```

- あなたは **北軍**。南軍は AI。
- **タイトル**: 数字 **`1`〜`5`** で戦地（レベル）選択 → **Enter / Space** で開始（Esc で終了）。テンキー可。
- **戦闘**: `Tab` 選択 / `W E S D Z C` 六方向移動 / `U` 取消 / `A` 攻撃（最弱優先） / `Enter` 手番終了  
  `+/-` ズーム・`0` 全体・`Shift+矢印` パン・`M` BGM消音

### レベル＝戦地（1〜5）

| Lv | 戦地 | 北軍（操作が増える） | 南軍 | 地形の意図 |
|----|------|----------------------|------|------------|
| 1 | アキア・クリーク (Aquia Creek) | 歩兵・将軍・騎馬（**兵力同等**） | 同規模 | クリーク／砲台（川西） |
| 2 | 第一次ブルラン (First Bull Run) | ＋銃撃 | やや強化 | Bull Run と丘 |
| 3 | 第二次ブルラン (Second Bull Run) | ＋大砲 | 将軍2など強化 | 尾根・街道 |
| 4 | ストーンズ川 (Stones River) | ＋近衛・物資輸送・将軍2 | 重装 | 中央の川帯 |
| 5 | ゲティスバーグ (Gettysburg) | ＋武器輸送など満載 | **最強**（将軍3・高ステ） | 尾根 / Round Top 寄り |

### ユニット

歩兵（汎用）、騎馬、武器輸送、物資輸送、大砲、**銃撃（射撃専門・近接弱）**、近衛、将軍（最大 3）

| 探知 | 内容 |
|------|------|
| 騎馬 | **4** hex。友軍から離れて徘徊し接触 |
| 銃撃 | **3** hex / 射程 **2** |
| その他 | **2** hex |
| 騎馬の秘匿 | 敵騎馬は距離 **2** まで見つかりにくい |
| 南軍 AI | 接触地点へ本隊を進軍 |

勝敗: 期間切れ→引き分け / 将軍 0→即敗北 / 損害 50%以上→敗北

---

## 現状

- [x] Godot 4 プロジェクト（`godot/`）
- [x] hex・キーボード・ターン・戦闘・勝敗
- [x] 南軍 AI・レベル1〜5（＝上記5戦地）・騎馬/銃撃の探知
- [ ] 以降は [plan.md](./plan.md)

---

## ルール（確定）

| 項目 | 内容 |
|------|------|
| 陣営 | 北軍 / 南軍・交互ターン |
| マップ | 六角。地形: 山・丘・砂地・街・道路・川・平地・谷間・岩地 |
| 操作 | キーボードのみ |
| 期間 | 戦地ごとにターン上限 |
| キャンペーン | 5 戦地。勝利数が多い側が「米国統一」 |
| セーブ | JSON（予定含む） |

---

## 技術（Godot）

| 項目 | 方針 |
|------|------|
| エンジン | Godot 4.x / GDScript |
| 描画・入力・音 | Godot 標準 |
| hex UI | テキスト/絵文字 + 簡易図形 |
| セーブ | `FileAccess` JSON |

---

## 開発方針

- Issue 駆動。親: [my-grok-task-2026#51](https://github.com/bluehive/my-grok-task-2026/issues/51)
- `main` 直接編集なし → 作業ブランチ → PR
- 環境: Linux Mint、Godot 4（mise 経由可）
- ローカル: `~/my-project/my-civilwargame-like`

```
my-civilwargame-like/
  plan.md
  README.md
  godot/            # Godot 4
  data/             # 共有データ予定
```

---

## ライセンス

リポジトリに `LICENSE` あり。

# HGNN-Parts - 次期バージョン (v2.0) 機能バックログ & 復元仕様書

本ファイルは、将来のバージョンで高度な機能（2点間移動、リンク連動、シーケンス、プリセット保存/読込、タイムライン）を再有効化するための開発内部記録です。ユーザー用ドキュメント（README / manual）には記載しません。

---

## 📋 将来復元対象の機能と既存スクリプト

| 機能名 | 対応スクリプト / メソッド | 概要 |
| :--- | :--- | :--- |
| **2点間移動 (TwoPoint)** | `res://scripts/motion_two_point.gd` | 始点 (Start Offset) と終点 (End Offset) 間の 3D 補間移動 |
| **リンク連動 (Linkage)** | `res://scripts/motion_linkage.gd` | 指定した主役パーツ (Driver) のトランスフォーム変位に追従 |
| **シーケンス (Sequence)** | `res://scripts/motion_sequence.gd` | パーツの動作（A → B → C）を順番に連続実行 |
| **プリセット保存/読込** | `ui_controller.gd` (`_on_save_preset_pressed`) | モーションパラメータの JSON シリアライズ & ファイルダイアログ保存 |
| **タイムライン** | `ui_controller.gd` (`_timeline_slider`) | シミュレーション経過時間の表示およびドラッグによるシーク |

---

## 🔧 再有効化（復元）手順

### 1. `OptionMotionType` の選択項目拡張 (`scenes/main.tscn`)
`OptionMotionType` の `item_count` を `6` に変更し、以下のアイテムを復元：
- `popup/item_3/text = "2点間移動"` (id: 3)
- `popup/item_4/text = "シーケンス"` (id: 4)
- `popup/item_5/text = "リンク連動"` (id: 5)

### 2. UI コントロールの動的構築復元 (`ui_controller.gd`)
`_ready()` 内で `_setup_motion_preset_and_timeline()` を呼び出すことで、プリセットボタンとタイムラインスライダーが「動作」タブに動的に配置されます。

### 3. モーション種類の分岐復元 (`ui_controller.gd`)
- `_on_motion_type_selected(index)`: index 3 (two_point), 4 (sequence), 5 (linkage) の分岐を有効化。
- `apply_motion_to_part(...)`: `"two_point"`, `"sequence"`, `"linkage"` の各 `ModelBehavior` インスタンス化処理を接続。
- `_sync_motion_ui_from_selected_part()`: `MotionTwoPoint`, `MotionSequence`, `MotionLinkage` の読み出しUI反映処理を復元。

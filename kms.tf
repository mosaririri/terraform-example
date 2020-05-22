resource "aws_kms_key" "example" {
  description = "Example Customer Master Key"
  enable_key_rotation = true
  is_enabled = true
  # 削除待機期間。通常はカスタマーマスターキーの削除は推奨されない。
  deletion_window_in_days = 30
}

#エイリアス設定
resource "aws_kms_alias" "example" {
  # エイリアスの設定時、「alias/」というプレフィックスを付けなければいけないらしい。
  name = "alias/example"
  target_key_id = aws_kms_key.example.key_id
}


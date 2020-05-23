# SSMパラメータストア

# # 平文でのパラメータ保存
resource "aws_ssm_parameter" "db_username" {
  name = "/db/username"
  value = "root"
  type = "String"
  description = "データベースのユーザー名"
}

# 暗号化でのパラメータ保存
resource "aws_ssm_parameter" "db_raw_password" {
  name = "/db/raw_password"
  value = "VeryStrongPassword!"
  type = "SecureString"
  description = "データベースのパスワード"
}

resource "aws_ssm_parameter" "db_password" {
  name = "/db/password"
  value = "uninitialized"
  type = "SecureString"
  description = "データベースのパスワード"

  lifecycle {
    ignore_changes = [ value ]
  }
}


# 暗号化することは可能だが、肝心の値を平文で入力することになるので、
# この設定情報が見られると結局元の値がバレてしまう。
# そのため、valueには仮の値を入れておき、
# apply後にCLIで値を更新する運用もあるらしい
# 
# aws logs filter-log-events --log-group-name /ecs-scheduled-tasks/example

#RDSの設定関連

# DBの設定
resource "aws_db_parameter_group" "example" {
  name = "example"
  family = "mysql5.7"

  parameter {
    name = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name = "character_set_server"
    value = "utf8mb4"
  }
}

# 
# DBエンジンにオプション機能を追加
resource "aws_db_option_group" "example" {
  name = "example"
  engine_name = "mysql"
  major_engine_version = "5.7"

  option {
    # MariaDB監査プラグイン
    # ユーザーのログインや実行クエリ等のアクティビティを記録する
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

# マルチAZ対応
resource "aws_db_subnet_group" "example" {
  name = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

# DBインスタンスの定義
# パスワードがtfstateに平文で書かれてしまうので、
# apply時は仮の値を入れておいて、apply後に変更したほうが良い
# aws rds modify-db-instance --db-instance-identifier 'example' \
# --master-user-password 'NewMasterPassword!'
#
# RDSを削除する場合、deletion_protectionをfalseに、
# skip_final_snapshotをtrueにしてapply後、destroyで削除できるらしい。

resource "aws_db_instance" "example" {
  identifier = "example"
  engine = "mysql"
  engine_version = "5.7.25"
  instance_class = "db.t3.small"
  allocated_storage = 20
  max_allocated_storage = 100
  # gp2 = 汎用SSD
  storage_type = "gp2"
  storage_encrypted = true
  kms_key_id = aws_kms_key.example.arn
  username = "admin"
  password = "VeryStrongPassword!"
  multi_az = true
  # マルチAZ対応時にはfalseにする
  publicly_accessible = false
  backup_window = "09:10-09:40"
  backup_retention_period = 30
  maintenance_window = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  # 削除保護
  deletion_protection = false
  skip_final_snapshot = true
  port = 3306
  # 設定変更を即時にするかどうか(falseを推奨)
  apply_immediately = false
  vpc_security_group_ids = [ module.mysql_sg.security_group_id ]
  parameter_group_name = aws_db_parameter_group.example.name
  option_group_name = aws_db_option_group.example.name
  db_subnet_group_name = aws_db_subnet_group.example.name

  lifecycle {
    ignore_changes = [ password ]
  }
}

module "mysql_sg" {
  source = "./security_group"
  name = "mesql-sg"
  vpc_id = aws_vpc.example.id
  port = 3306
  cidr_blocks = [ aws_vpc.example.cidr_block ]
}

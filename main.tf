#provider

provider "aws" {
  region  = var.region
  profile = "default"
}

#ec2 instance

/* data "aws_ami" "tf_ami" {
  owners      = ["amazon"]
  most_recent = true
  filters {
    name   = "name"
    values = ["amzn-ami-hvm-2018.03.0.20200206.0-x86_64-gp2"]
  }
  #ami-0e2ff28bfb72a4e45
} */

resource "aws_instance" "tf_bastion" {
  instance_type = var.instance_type
  ami           = "ami-0e2ff28bfb72a4e45"
  tags = {
    Name = "tf_server_bastion"
  }
  key_name               = aws_key_pair.tf_auth.id
  vpc_security_group_ids = [aws_security_group.tf_sg_public.id]
  subnet_id              = aws_subnet.tf_subnet_public.id
}

resource "aws_db_subnet_group" "tf_db_subnet_group" {
  name       = "tf_db_subnet_group"
  subnet_ids = [aws_subnet.tf_subnet_private.id, aws_subnet.tf_subnet_private2.id]
  #subnet_ids = [aws_subnet.tf_subnet_private.id]
}
/* resource "aws_db_instance" "tf_db" {
  allocated_storage           = 20
  allow_major_version_upgrade = false
  apply_immediately           = false
  auto_minor_version_upgrade  = false
  db_subnet_group_name        = aws_db_subnet_group.tf_db_subnet_group.name
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.6"
  instance_class              = "db.t2.small"
  multi_az                    = true
  port                        = "3306"
  vpc_security_group_ids      = [aws_security_group.tf_sg_private.id]
  name                        = "mydb"
  username                    = "amex1234"
  password                    = "amex1234"
  final_snapshot_identifier   = "finalsnapshot"
  skip_final_snapshot         = true
} */


resource "aws_rds_cluster" "aurora-cluster-ci" {
  cluster_identifier      = "aurora-cluster-ci"
  engine                  = "aurora-mysql"
  availability_zones      = [data.aws_availability_zones.tf_azs.names[0], data.aws_availability_zones.tf_azs.names[1]]
  database_name           = "mydb"
  master_username         = "admin"
  master_password         = "amex1234"
  vpc_security_group_ids  = [aws_security_group.tf_sg_private.id]
  db_subnet_group_name    = aws_db_subnet_group.tf_db_subnet_group.name
  backup_retention_period = 5
  #engine_version            = "5.7.mysql_aurora.2.03.2"
  preferred_backup_window   = "07:00-09:00"
  apply_immediately         = true
  final_snapshot_identifier = "ci-aurora-cluster-backup"
  skip_final_snapshot       = true
  deletion_protection       = false
  tags = {
    Name = "my_aur_db"
  }
}

resource "aws_rds_cluster_instance" "myaur" {
  count              = 2
  identifier         = "aurora-cluster-ci-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora-cluster-ci.id
  instance_class     = "db.t2.small"
  engine             = "aurora-mysql"
  tags = {
    Name = "mydbinstance-${count.index}"
  }
}

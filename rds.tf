resource "aws_db_subnet_group" "rakam-rds" {
  name        = "terraform-rds-rakam-db-subnet-group"
  description = "Group of subnets for rds"
  subnet_ids  = "${aws_subnet.rakam.*.id}"
}

resource "aws_security_group" "rakam-rds" {
  name        = "terraform-rds-rakam-security-group"
  description = "Security group for RDS, nodes need to access"
  vpc_id      = "${aws_vpc.rakam.id}"
  tags = {
     "Name" = "terraform-rds-rakam-mysql"
  }
}

resource "aws_security_group_rule" "rakam-rds-mysql-to-nodes" {
  description              = "Allow eks nodes to communicate with the rds server"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.rakam-rds.id}"
  source_security_group_id = "${aws_security_group.rakam-node.id}"
  to_port                  = 3306
  type                     = "ingress"
}

resource "aws_db_instance" "rakammysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "rakammysql"
  username             = "${var.rakam-rds-username}"
  password             = "${var.rakam-rds-password}"
  parameter_group_name = "default.mysql5.7"
  multi_az             = true
  db_subnet_group_name = "${aws_db_subnet_group.rakam-rds.id}"
  vpc_security_group_ids = ["${aws_security_group.rakam-rds.id}"]
  # final_snapshot_identifier = "foo" Upon deletion
  backup_retention_period = "30"
  backup_window = "03:00-04:00" # In UTC
}
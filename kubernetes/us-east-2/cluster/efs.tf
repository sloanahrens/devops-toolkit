resource "aws_efs_file_system" "efs-us-east-2-k8s-local" {
}

resource "aws_efs_mount_target" "us-east-2b-us-east-2-k8s-local" {
  file_system_id = "${aws_efs_file_system.efs-us-east-2-k8s-local.id}"
  subnet_id      = "${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"

  security_groups = [
    "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}",
  ]
}

output "efs_id" {
  value = "${aws_efs_file_system.efs-us-east-2-k8s-local.id}"
}
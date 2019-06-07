locals = {
  cluster_name                      = "devops-toolkit-us-east-2.k8s.local"
  master_autoscaling_group_ids      = ["${aws_autoscaling_group.master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local.id}"]
  master_security_group_ids         = ["${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"]
  masters_role_arn                  = "${aws_iam_role.masters-devops-toolkit-us-east-2-k8s-local.arn}"
  masters_role_name                 = "${aws_iam_role.masters-devops-toolkit-us-east-2-k8s-local.name}"
  node_autoscaling_group_ids        = ["${aws_autoscaling_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"]
  node_security_group_ids           = ["${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"]
  node_subnet_ids                   = ["${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"]
  nodes_role_arn                    = "${aws_iam_role.nodes-devops-toolkit-us-east-2-k8s-local.arn}"
  nodes_role_name                   = "${aws_iam_role.nodes-devops-toolkit-us-east-2-k8s-local.name}"
  region                            = "us-east-2"
  route_table_private-us-east-2b_id = "${aws_route_table.private-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  route_table_public_id             = "${aws_route_table.devops-toolkit-us-east-2-k8s-local.id}"
  subnet_us-east-2b_id              = "${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  subnet_utility-us-east-2b_id      = "${aws_subnet.utility-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  vpc_cidr_block                    = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.cidr_block}"
  vpc_id                            = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
}

output "cluster_name" {
  value = "devops-toolkit-us-east-2.k8s.local"
}

output "master_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local.id}"]
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-devops-toolkit-us-east-2-k8s-local.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-devops-toolkit-us-east-2-k8s-local.name}"
}

output "node_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-devops-toolkit-us-east-2-k8s-local.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-devops-toolkit-us-east-2-k8s-local.name}"
}

output "region" {
  value = "us-east-2"
}

output "route_table_private-us-east-2b_id" {
  value = "${aws_route_table.private-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
}

output "route_table_public_id" {
  value = "${aws_route_table.devops-toolkit-us-east-2-k8s-local.id}"
}

output "subnet_us-east-2b_id" {
  value = "${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
}

output "subnet_utility-us-east-2b_id" {
  value = "${aws_subnet.utility-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.cidr_block}"
}

output "vpc_id" {
  value = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_autoscaling_attachment" "master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local" {
  elb                    = "${aws_elb.api-devops-toolkit-us-east-2-k8s-local.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local.id}"
}

resource "aws_autoscaling_group" "master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local" {
  name                 = "master-us-east-2b.masters.devops-toolkit-us-east-2.k8s.local"
  launch_configuration = "${aws_launch_configuration.master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "devops-toolkit-us-east-2.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-east-2b.masters.devops-toolkit-us-east-2.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-east-2b"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-devops-toolkit-us-east-2-k8s-local" {
  name                 = "nodes.devops-toolkit-us-east-2.k8s.local"
  launch_configuration = "${aws_launch_configuration.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "devops-toolkit-us-east-2.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.devops-toolkit-us-east-2.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "b-etcd-events-devops-toolkit-us-east-2-k8s-local" {
  availability_zone = "us-east-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "b.etcd-events.devops-toolkit-us-east-2.k8s.local"
    "k8s.io/etcd/events"                                       = "b/b"
    "k8s.io/role/master"                                       = "1"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_ebs_volume" "b-etcd-main-devops-toolkit-us-east-2-k8s-local" {
  availability_zone = "us-east-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "b.etcd-main.devops-toolkit-us-east-2.k8s.local"
    "k8s.io/etcd/main"                                         = "b/b"
    "k8s.io/role/master"                                       = "1"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_eip" "us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  vpc = true

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "us-east-2b.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_elb" "api-devops-toolkit-us-east-2-k8s-local" {
  name = "api-devops-toolkit-us-eas-9tlu1h"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-devops-toolkit-us-east-2-k8s-local.id}"]
  subnets         = ["${aws_subnet.utility-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "api.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-devops-toolkit-us-east-2-k8s-local" {
  name = "masters.devops-toolkit-us-east-2.k8s.local"
  role = "${aws_iam_role.masters-devops-toolkit-us-east-2-k8s-local.name}"
}

resource "aws_iam_instance_profile" "nodes-devops-toolkit-us-east-2-k8s-local" {
  name = "nodes.devops-toolkit-us-east-2.k8s.local"
  role = "${aws_iam_role.nodes-devops-toolkit-us-east-2-k8s-local.name}"
}

resource "aws_iam_role" "masters-devops-toolkit-us-east-2-k8s-local" {
  name               = "masters.devops-toolkit-us-east-2.k8s.local"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.devops-toolkit-us-east-2.k8s.local_policy")}"
}

resource "aws_iam_role" "nodes-devops-toolkit-us-east-2-k8s-local" {
  name               = "nodes.devops-toolkit-us-east-2.k8s.local"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.devops-toolkit-us-east-2.k8s.local_policy")}"
}

resource "aws_iam_role_policy" "masters-devops-toolkit-us-east-2-k8s-local" {
  name   = "masters.devops-toolkit-us-east-2.k8s.local"
  role   = "${aws_iam_role.masters-devops-toolkit-us-east-2-k8s-local.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.devops-toolkit-us-east-2.k8s.local_policy")}"
}

resource "aws_iam_role_policy" "nodes-devops-toolkit-us-east-2-k8s-local" {
  name   = "nodes.devops-toolkit-us-east-2.k8s.local"
  role   = "${aws_iam_role.nodes-devops-toolkit-us-east-2-k8s-local.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.devops-toolkit-us-east-2.k8s.local_policy")}"
}

resource "aws_internet_gateway" "devops-toolkit-us-east-2-k8s-local" {
  vpc_id = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_key_pair" "kubernetes-devops-toolkit-us-east-2-k8s-local-7585ac2a94d1c707f159682ffefd6a74" {
  key_name   = "kubernetes.devops-toolkit-us-east-2.k8s.local-75:85:ac:2a:94:d1:c7:07:f1:59:68:2f:fe:fd:6a:74"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.devops-toolkit-us-east-2.k8s.local-7585ac2a94d1c707f159682ffefd6a74_public_key")}"
}

resource "aws_launch_configuration" "master-us-east-2b-masters-devops-toolkit-us-east-2-k8s-local" {
  name_prefix                 = "master-us-east-2b.masters.devops-toolkit-us-east-2.k8s.local-"
  image_id                    = "ami-033476a646ce264ac"
  instance_type               = "c4.large"
  key_name                    = "${aws_key_pair.kubernetes-devops-toolkit-us-east-2-k8s-local-7585ac2a94d1c707f159682ffefd6a74.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-devops-toolkit-us-east-2-k8s-local.id}"
  security_groups             = ["${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-east-2b.masters.devops-toolkit-us-east-2.k8s.local_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-devops-toolkit-us-east-2-k8s-local" {
  name_prefix                 = "nodes.devops-toolkit-us-east-2.k8s.local-"
  image_id                    = "ami-033476a646ce264ac"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-devops-toolkit-us-east-2-k8s-local-7585ac2a94d1c707f159682ffefd6a74.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  security_groups             = ["${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.devops-toolkit-us-east-2.k8s.local_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_nat_gateway" "us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  allocation_id = "${aws_eip.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  subnet_id     = "${aws_subnet.utility-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "us-east-2b.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.devops-toolkit-us-east-2-k8s-local.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.devops-toolkit-us-east-2-k8s-local.id}"
}

resource "aws_route" "private-us-east-2b-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
}

resource "aws_route_table" "devops-toolkit-us-east-2-k8s-local" {
  vpc_id = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                  = "public"
  }
}

resource "aws_route_table" "private-us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  vpc_id = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "private-us-east-2b.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
    "kubernetes.io/kops/role"                                  = "private-us-east-2b"
  }
}

resource "aws_route_table_association" "private-us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  subnet_id      = "${aws_subnet.us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  route_table_id = "${aws_route_table.private-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
}

resource "aws_route_table_association" "utility-us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  subnet_id      = "${aws_subnet.utility-us-east-2b-devops-toolkit-us-east-2-k8s-local.id}"
  route_table_id = "${aws_route_table.devops-toolkit-us-east-2-k8s-local.id}"
}

resource "aws_security_group" "api-elb-devops-toolkit-us-east-2-k8s-local" {
  name        = "api-elb.devops-toolkit-us-east-2.k8s.local"
  vpc_id      = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "api-elb.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_security_group" "masters-devops-toolkit-us-east-2-k8s-local" {
  name        = "masters.devops-toolkit-us-east-2.k8s.local"
  vpc_id      = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "masters.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_security_group" "nodes-devops-toolkit-us-east-2-k8s-local" {
  name        = "nodes.devops-toolkit-us-east-2.k8s.local"
  vpc_id      = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "nodes.devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.api-elb-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "icmp-pmtu-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 3
  to_port           = 4
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4001" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 2382
  to_port                  = 4001
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-devops-toolkit-us-east-2-k8s-local.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  vpc_id            = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "us-east-2b"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "us-east-2b.devops-toolkit-us-east-2.k8s.local"
    SubnetType                                                 = "Private"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
    "kubernetes.io/role/internal-elb"                          = "1"
  }
}

resource "aws_subnet" "utility-us-east-2b-devops-toolkit-us-east-2-k8s-local" {
  vpc_id            = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
  cidr_block        = "172.20.0.0/22"
  availability_zone = "us-east-2b"

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "utility-us-east-2b.devops-toolkit-us-east-2.k8s.local"
    SubnetType                                                 = "Utility"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
    "kubernetes.io/role/elb"                                   = "1"
  }
}

resource "aws_vpc" "devops-toolkit-us-east-2-k8s-local" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "devops-toolkit-us-east-2-k8s-local" {
  domain_name         = "us-east-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                                          = "devops-toolkit-us-east-2.k8s.local"
    Name                                                       = "devops-toolkit-us-east-2.k8s.local"
    "kubernetes.io/cluster/devops-toolkit-us-east-2.k8s.local" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "devops-toolkit-us-east-2-k8s-local" {
  vpc_id          = "${aws_vpc.devops-toolkit-us-east-2-k8s-local.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.devops-toolkit-us-east-2-k8s-local.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}

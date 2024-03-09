###############################
###     TARGET-GROUP        ###
###############################

resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-${var.common_tags.Component}"
  port     = var.target_group_port_num
  protocol = var.target_group_protocal
  vpc_id   = var.vpc_id

  health_check {
    enabled = var.health_check.enabled
    interval = var.health_check.interval
    path = var.health_check.path
    port = var.health_check.port
    protocol = var.health_check.protocol
    timeout = var.health_check.timeout
    healthy_threshold = var.health_check.healthy_threshold # consider as Healthy if 2 health checks are success
    unhealthy_threshold = var.health_check.unhealthy_threshold # consider as Un-Healthy if 3 health checks are failes
    matcher = var.health_check.matcher # Health check is success if HTTP status code in between 200-299
  }

  tags = var.common_tags
}

##################################
###     LAUNCH-TEMPLATE        ###
##################################

resource "aws_launch_template" "main" {
  name = "${var.project_name}-${var.common_tags.Component}"
  image_id = var.image_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.instance_type
  vpc_security_group_ids = [var.vpc_security_group_ids]

  ### Creating loop for multiple tag specifications
  dynamic tag_specifications {
    for_each = var.launch_template_tags
    content {
      resource_type = tag_specifications.value["resource_type"]
      tags = tag_specifications.value["tags"]
    }
  }

  user_data = var.user_data
}


###################################
###         AUTO-SCALING        ###
###################################

resource "aws_autoscaling_group" "main" {
  name                      = "${var.project_name}-${var.common_tags.Component}"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
 
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns = [aws_lb_target_group.main.arn]
  timeouts {
    delete = "15m"
  }

  # tag {
  #   key                 = "Name"
  #   value               = "Catalogue"
  #   propagate_at_launch = true
  # }
  dynamic tag {
    for_each = var.autoscaling_tags
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"] # boolean value
    }

  } 
}

###################################
###     AUTO-SCALING-POLICY     ###
###################################

resource "aws_autoscaling_policy" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  name                   = "cpu"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.autoscaling_cpu_target_value
  }
}

################################
###     LISTNERS             ###
################################

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.web_alb_listener_arn
  priority     = var.listner_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = var.host_header
    }
  }
}





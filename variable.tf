variable "project_name" {
    
}

variable "environment" {
  
}

variable "Component" {
  
}
variable "common_tags" {
 
}

variable "target_group_port_num" {
    default = 8080
}

variable "target_group_protocal" {
    default = "HTTP"
}

variable "vpc_id" {

}

variable "health_check" {       
    default = {
        enabled = true
        interval = 15
        path = "/health"
        port = 8080
        protocol = "HTTP"
        timeout = 5
        healthy_threshold = 2 # consider as Healthy if 2 health checks are success
        unhealthy_threshold = 3 # consider as Un-Healthy if 3 health checks are failes
        matcher = "200-299" # Health check is success if HTTP status code in between 200-299
    }
}

variable "user_data" {
    default = {}
}

variable "launch_template_tags" {
    default = []
}

variable "instance_type" {
    default = "t2.micro"
}

variable "image_id" {
    
}

variable "vpc_security_group_ids" {

}

variable "tag" {
    default = {}
}

variable "max_size" {
    default = 10
}

variable "min_size" {
    default = 1
}

variable "desired_capacity" {
    default = 2
}

variable "health_check_grace_period" {
    default = 300
}

variable "health_check_type" {
    default = "ELB"
}

variable "vpc_zone_identifier" {
  type = list
}

variable "autoscaling_tags" {
    default = []
}

variable "autoscaling_cpu_target_value" {
  default = 70.0
}

variable "web_alb_listener_arn" {

}

variable "host_header" {
    default = []
}

variable "listner_rule_priority" {

}
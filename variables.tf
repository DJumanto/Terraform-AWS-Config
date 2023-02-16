variable "AWS_SECRET_ACCESS_KEY" {
    type = string
    default = null
}
variable "AWS_ACCESS_KEY_ID" {
    type = string
    default = null
}
variable "aws_region" {
    description = "Region for AWS EC2 instances"
    default = "ap-southeast-1"
}

variable "instance_type" {
    description = "instance type for EC2 instance"
    default = "t2.micro"
}

variable "tag_name" {
    description = "Tag name for EC2 intance"
    default = "EC2 Instance"
}

variable "ami_id"{
    description = "AMI instance ID"
    default = "ami-082b1f4237bd816a1"
}

variable "key_pair"{
    description = "Key to access Instance via ssh"
    default = "Lab-AJK-WebServer"
}

variable "security_group"{
    description = "Security Group"
    default = "UFW Enable"
}
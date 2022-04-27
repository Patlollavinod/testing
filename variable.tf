variable "aws_region" {
    default = "ap-south-1"
}

variable "ec2_ami" {
    default = "ami-0851b76e8b1bce90b"  #ubuntu
}

variable "instance_type" {
    default = "t2.micro"
}

variable  "ec2_keypair" {
    default = "jenkins-pipelines"
}

variable "ec2_count" {
    type = number
    default = "2"
}

variable "vpc_security_group" {
    default = ["sg-0753487fac46f2272"]
}

variable "environment" {
    default ="dev"
}

variable "product" {
    default = "server"
}

variable "subnets" {
    type = list
    default = ["subnet-0bee8832e401ccc6b", "subnet-01d1fa65065bf0797"]
}

variable "vpc_id" {
    default = "vpc-05fdf739745f2db7f"
}

variable "instance1_id" {
    default = "i-011de0b3875e2d565"
}

variable "instance2_id" {
    default = "i-000c713c42d9a7532"
}


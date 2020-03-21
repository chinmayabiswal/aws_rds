variable "sub_pub_cidr" {
  default = "10.88.140.0/24"
}
variable "sub_pri_cidr1" {
  default = "10.88.141.0/24"
}
variable "sub_pri_cidr2" {
  default = "10.88.139.0/24"
}
variable "vpc_cidr" {
  default = "10.88.128.0/20"
}
variable "region" {
  default = "us-east-1"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "pub_key" {
  default = "/home/cbiswa/.ssh/public.pub"
}

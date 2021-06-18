variable "access_key" {
   default = "access key for the dev environment"
}
variable "secret_key" {
   default = "secret key for the dev environment"
}
variable "region" {
   default = "us-east-1"
}
variable "availabilityZone" {
   default = "us-east-1b"
}
variable "instanceType" {
   default = "t2.micro"
}
variable "keyName" {
   default = "pasan-test"
}
variable "keyPath" {
   default = "~/pasan-test.pem"
}
variable "subnet" {
   default = "subnet-xxxxx"
}
variable "securityGroups" {
   type = list
   default = [ "sg-xxxx" ]
}
variable "instanceName" {
   default = "buildbook-dev"
}
variable "amis" {
   default = {
     "us-east-1" = "ami-0b898040803850657"
   }
}

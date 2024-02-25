variable "aws_credentials_file" { #Todo: uncomment the default value and add your access key.
        description = "Credenttail file path"
        default = "C:\Users\user\Desktop\수근개인공부\AWS_Kubernets_with_Terraform\.aws\credentials.txt" 
}

variable "aws_profile" { #Todo: uncomment the default value and add your access key.
        description = "aws profile"
        default = "test" 
}

variable "ami_key_pair_name" { #Todo: uncomment the default value and add your pem key pair name. Hint: don't write '.pem' exction just the key name
        default = "deploy-key"         
}

variable "number_of_worker" {
        description = "number of worker instances to be join on cluster."
        default = 2
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0a6b2839d44d781b2" #Ubuntu 20.04
}

variable "instance_type" {
        default = "t2.medium" #the best type to start k8s with it,
}
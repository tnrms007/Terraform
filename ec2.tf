resource "aws_instance" "k8s_master" {
    ami = var.ami_id
    subnet_id = aws_subnet.k8s_public_subnet.id
    instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    security_groups = [ aws_security_group.k8s_sg.id ]
    user_data_base64 = base64encode("${templatefile("scripts/install_k8s_master.sh")}")    
    root_block_device {
    volume_type = "gp3"
    volume_size = "10"
    delete_on_termination = true
    }  

    tags = {
        Name = "ksgcluster_master"
        provider = "terraform"
    }
}

resource "aws_instance" "k8s_worker" {
    ami = var.ami_id
    subnet_id = aws_subnet.k8s_public_subnet.id
    instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    count = var.number_of_worker
    associate_public_ip_address = true
    security_groups = [ aws_security_group.k8s_sg.id ]
    root_block_device {
    volume_type = "gp3"
    volume_size = "10"
    delete_on_termination = true
    
    }
    
    user_data_base64 = base64encode("${templatefile("scripts/install_k8s_worker.sh", {
    worker_number = "${count.index + 1}"
    })}")    

    tags = {
        Name = "ksgcluster_worker${count.index + 1}"
        provider = "terraform"
    }
}

resource "aws_ebs_volume" "master_external_volume" {
  count             = 2
  availability_zone = aws_instance.k8s_master.availability_zone
  size              = 10
  type              = "gp3"
  tags = {
    Name = "MasterExternalVolume${count.index + 1}"
  }
}

resource "aws_ebs_volume" "worker_external_volume" {
  count             = 2 * var.number_of_worker
  availability_zone = element(aws_instance.k8s_worker.*.availability_zone, count.index / 2)
  size              = 10
  type              = "gp3"
  tags = {
    Name = "WorkerExternalVolume${count.index + 1}"
  }
}

resource "aws_volume_attachment" "master_ebs_attach" {
  count       = 2
  device_name = count.index == 0 ? "/dev/sdb" : "/dev/sdc"
  volume_id   = aws_ebs_volume.master_external_volume[count.index].id
  instance_id = aws_instance.k8s_master.id
}

resource "aws_volume_attachment" "worker_ebs_attach" {
  count       = 2 * var.number_of_worker
  device_name = count.index % 2 == 0 ? "/dev/sdb" : "/dev/sdc"
  volume_id   = aws_ebs_volume.worker_external_volume[count.index].id
  instance_id = element(aws_instance.k8s_worker.*.id, count.index / 2)
}


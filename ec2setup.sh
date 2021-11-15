#!/bin/bash
sudo yum update -y
sudo yum install java-1.8.0 -y
sudo yum install docker -y
cd /home/ec2-user
#java home
echo 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64/jre"' >>/home/ec2-user/.bashrc
echo 'PATH=$JAVA_HOME/bin:$PATH' >>/home/ec2-user/.bashrc
source /home/ec2-user/.bashrc
#kafka install
wget https://archive.apache.org/dist/kafka/2.6.2/kafka_2.12-2.6.2.tgz -P /home/ec2-user
tar -xzf kafka_2.12-2.6.2.tgz

#COMMANDS TO ENTER MANUALLY IF YOU WANT TO USE DOCKER AS NON ROOT USER
#sudo groupadd docker
#sudo usermod -aG docker $USER
#newgrp docker

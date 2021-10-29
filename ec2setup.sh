#!/bin/bash
sudo yum update -y
sudo yum install java-1.8.0 -y
cd /home/ec2-user
echo 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.aarch64/jre"' >>/home/ec2-user/.bashrc
echo 'PATH=$JAVA_HOME/bin:$PATH' >>/home/ec2-user/.bashrc
source /home/ec2-user/.bashrc
wget https://archive.apache.org/dist/kafka/2.6.2/kafka_2.12-2.6.2.tgz -P /home/ec2-user
tar -xzf kafka_2.12-2.6.2.tgz

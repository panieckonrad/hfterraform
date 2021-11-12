To automatically upload custom connector plugin to s3 download
https://www.confluent.io/hub/confluentinc/kafka-connect-s3 and put it in 
~/Downloads

after that run 'terraform apply'
and it should setup the whole infrastructure.

In order to produce messages to msk from your local machine
you need to create an ssh tunnel to forward your requests to msk:
1. for mac create network interfaces:
sudo ifconfig lo0 alias 127.0.0.2 up <br />
sudo ifconfig lo0 alias 127.0.0.3 up <br />
sudo ifconfig lo0 alias 127.0.0.4 up <br />
sudo ifconfig lo0 alias 127.0.0.5 up <br />
2. create a config file under ~/.ssh/config <br/>
YOU NEED TO CHANGE HOSTNAME, ZOOKEEPER IPS AND BROKER IPS! <br/>
Host hfbastion <br />
ServerAliveInterval 30<br />
Hostname 54.78.142.160#CHANGEME<br />
User ec2-user<br />
IdentityFile <path to access key for ec2 (.pem)> #CHANGEME<br />
LocalForward 127.0.0.1:9092 b-1.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:9092 #CHANGEME<br />
LocalForward 127.0.0.2:9092 b-2.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:9092 #CHANGEME<br />
LocalForward 127.0.0.3:2181 z-1.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:2181 #CHANGEME<br />
LocalForward 127.0.0.4:2181 z-2.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:2181 #CHANGEME<br />
LocalForward 127.0.0.5:2181 z-3.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:2181 #CHANGEME<br />
LocalForward 127.0.0.1:8081 10.0.2.50:8081 <br />
3. Modify /etc/hosts file <br />
127.0.0.1 b-1.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com #CHANGEME <br />
127.0.0.2 b-2.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com #CHANGEME<br />

according to: https://stackoverflow.com/questions/49618852/mac-osx-forwarding-hostname-traffic-to-ssh-tunnel 

4. Run in console command 'ssh hfbastion'
5. As long as you are sshed to hfbastion, localhost:9092 on your local computer will forward to the broker ip of msk.
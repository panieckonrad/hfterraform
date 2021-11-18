IMPORTANT: You need to change s3 bucket name in terraform.tfvars <br/> <br/>
after that run ```terraform apply``` and it should setup the whole infrastructure. 
run ```terraform output``` to see ec2 ip and broker connection strings

##In order to produce messages to msk from your local machine you need to create an ssh tunnel to forward your requests to
msk:

1. for mac create network interfaces:
   sudo ifconfig lo0 alias 127.0.0.2 up <br />
   sudo ifconfig lo0 alias 127.0.0.3 up <br />
   sudo ifconfig lo0 alias 127.0.0.4 up <br />
   sudo ifconfig lo0 alias 127.0.0.5 up <br />
2. create a config file under ~/.ssh/config <br/>
   YOU NEED TO CHANGE HOSTNAME, ZOOKEEPER IPS AND BROKER IPS (use bootstrap_brokers, not tls)! <br/> <br/>
   Host hfbastion <br />
   ServerAliveInterval 30<br />
   Hostname 54.78.142.160#CHANGEME<br />
   User ec2-user<br />
   IdentityFile <path to access key for ec2 (.pem)> #CHANGEME<br />
   LocalForward 127.0.0.1:9092 b-1.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:9092 #CHANGEME<br />
   LocalForward 127.0.0.2:9092 b-2.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:9092 #CHANGEME<br />
   LocalForward 127.0.0.3:2181 z-1.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:2181 #CHANGEME<br />
   LocalForward 127.0.0.4:2181 z-2.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:2181 #CHANGEME<br />
   LocalForward 127.0.0.5:2181 z-3.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com:2181 #CHANGEME<br /> <br />
3. Modify /etc/hosts file <br />
   127.0.0.1 b-1.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com #CHANGEME <br />
   127.0.0.2 b-2.hf-msk.4vlngt.c9.kafka.eu-west-1.amazonaws.com #CHANGEME<br />

 guide: https://stackoverflow.com/questions/49618852/mac-osx-forwarding-hostname-traffic-to-ssh-tunnel

4. Run in console command ```ssh hfbastion```
5. As long as you are sshed to hfbastion, ```localhost:9092``` on your local computer will forward to the broker ip of msk.

Now we need to create a topic for our avro messages:
- On hfbastion (ec2 instance) run commands: <br/>
``` cd /home/ec2-user/kafka_2.12-2.6.2 ``` <br/>
```bin/kafka-topics.sh --create --zookeeper <zookeeper_connect_string from 'terraform output'> --replication-factor 2 --partitions 1 --topic awsuseravro1```

After you have created the topic clone this repo on your local computer:
https://github.com/panieckonrad/avrovsproto <br/>

launch the AwsAvroProducer.class which should produce 10 messages in avro format and put in 'awsuseravro1' topic. It will automatically register the schema on aws glue registry.


##Create custom plugin
Upload the connector plugin to your s3.

https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-plugins.html
#Create AWS MSK connector
Create connector following this guide: https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-connectors.html
Don't forget to create a cloudwatch group and send the logs to it.
Use following configs for connector: <br/>
```connector.class=io.confluent.connect.s3.S3SinkConnector
s3.region=eu-west-1
flush.size=1
schema.compatibility=FULL
tasks.max=2
topics=awsuseravro1
format.class=io.confluent.connect.s3.format.avro.AvroFormat
partitioner.class=io.confluent.connect.storage.partitioner.DefaultPartitioner
storage.class=io.confluent.connect.s3.storage.S3Storage
s3.bucket.name=<YOUR_S3_BUCKET_NAME>!!!!!!!!!!!!
topics.dir=avrotopics1
key.converter=com.amazonaws.services.schemaregistry.kafkaconnect.AWSKafkaAvroConverter
value.converter=com.amazonaws.services.schemaregistry.kafkaconnect.AWSKafkaAvroConverter
key.converter.region=eu-west-1
value.converter.region=eu-west-1
key.converter.schemaAutoRegistrationEnabled=true
value.converter.schemaAutoRegistrationEnabled=true
key.converter.avroRecordType=GENERIC_RECORD
value.converter.avroRecordType=GENERIC_RECORD
key.converter.schemaName=awsuseravro1
value.converter.schemaName=awsuseravro1
key.converter.registry.name=msk-registry
value.converter.registry.name=msk-registry
```
Choose s3kafkaconnectrole1 for the role of the connector.

#!/bin/bash
#Author 
#****HAMMAD****#
#****email:-hammad@matesio.com****#
#including external scripts for log and other fucntions 

source includes/script_helper.sh
#This function check for java installation
#if installation not found,oracle-java8 will be installed



function installJava {
	log "Downloading and installing oracle java"
	if (type "xterm" > /dev/null);then
		log "requirement already satisfied"
	else
		add-apt-repository ppa:webupd8team/java
		apt-get update
		apt-get install oracle-java8-installer
	fi
}
#This function
#Downloads hadoop from the hadoop download link
#Extract it to a folder
#move to /usr/local/hadoop


function DownloadHadoop {
	log "Downloading hadoop"
	cd  ~/Downloads
	tryexec wget http://www-eu.apache.org/dist/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz 
	mkdir /usr/local/hadoop
	chmod 777 -R /usr/local/hadoop

	tryexec tar -xzf ~/Downloads/hadoop-2.7.4.tar.gz  
	cd hadoop-2.7.4
	sudo mv * /usr/local/hadoop
}

function creatingDirectories {
	log "creating hadoop directories"

	tryexec mkdir -p /app/hadoop/tmp
	tryexec chmod 750 /app/hadoop/tmp

}


function editConfigurations{
	cd /usr/local/hadoop/etc/hadoop

	tryexec cat <<EOF > core-site.xml

	<?xml version="1.0"?>
	<!-- core-site.xml -->
	<configuration>
	<property>
    <name>hadoop.tmp.dir</name>
    <value>/app/hadoop/tmp</value>
	</property>

	<property>
    <name>fs.default.name</name>
    <value>hdfs://localhost:54310</value>
   
	</property>
EOF
	tryexec cp mapred-site.xml.template mapred-site.xml
	tryexec cat <<EOF > mapred-site.xml
	

	<?xml version="1.0"?>
	<!-- mapred-site.xml -->
	<configuration>
	<property>
	<name>mapred.job.tracker</name>
    <value>localhost:54311</value>   
	</property>
	</configuration>

EOF
	tryexec cat <<EOF > hdfs-site.xml

	<?xml version="1.0"?>
	<!-- mapred-site.xml -->
	<configuration>
	<property>
    <name>dfs.replication</name>
    <value>1</value>
	</property>
	</configuration>
EOF	
}

function setupEnvVars {
	log "creating hadoop environment variables"
	
	cat <<EOF >> ~/.bashrc
	export HADOOP_INSTALL=/usr/local/hadoop
	export PATH=$PATH:$HADOOP_INSTALL/bin
	export PATH=$PATH:$HADOOP_INSTALL/sbin
	export HADOOP_MAPRED_HOME=$HADOOP_INSTALL
	export HADOOP_COMMON_HOME=$HADOOP_INSTALL
	export HADOOP_HDFS_HOME=$HADOOP_INSTALL
EOF
	tryexec source ~/.bashrc
}

function formatHdfs {
    log "formatting HDFS"
    hadoop  namenode -format
}

function startDaemons {
    start-all.sh
}

function setupHdfs {
    log "creating user home directory in hdfs"
    hadoop fs  -mkdir -p /user/root
    hadoop fs  -mkdir -p /user/hammad
    hadoop fs  -chown hammad:hammad /user/hammad

    log "creating temp directories in hdfs"
    hadoop fs  -mkdir -p /tmp
    hadoop fs  -chmod -R 777 /tmp
    hadoop fs  -mkdir -p /var
    hadoop fs  -chmod -R 777 /var
}

log ("Hadoop installation")

rootcheck
installHadoop
creatingDirectories
editConfigurations
setupEnvVars
formatHdfs
startDaemons
setupHdfs

log "Installation Completed Successfully!!!"


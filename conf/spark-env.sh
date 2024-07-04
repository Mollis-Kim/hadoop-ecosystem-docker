export SPARK_HOME=/molils/spark
export HADOOP_HOME=/molils/hadoop3
export PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

export SPARK_WORKER_CORES=2  # default: all available
export SPARK_WORKER_MEMORY=2G  # default: machine's total RAM minus 1 GiB
export SPARK_MASTER_OPTS="-Dspark.deploy.defaultCores=5"
export SPARK_LOCAL_DIRS=$SPARK_HOME/local
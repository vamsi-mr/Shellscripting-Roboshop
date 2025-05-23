#/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
g="\e[32m"
y="\e[33m"
N="\e[0m"
LOGSFOLDER="/var/log/roboshop"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGSFOLDER/$SCRIPTNAME.log
SCRIPT_DIR=$PWD

        mkdir -p $LOGSFOLDER
        echo "Script executed at : $(date)" | tee -a $LOG_FILE

    if [ $USERID -ne 0 ]
    then    
        echo -e "{$R} ERROR : Please run with root access {$N}" | tee -a $LOG_FILE
        exit 1
    else    
        echo -e "{$Y} You are running with root access {$N}" | tee -a $LOG_FILE
    fi
    
    echo "Please enter rabbitmq password to setup"
    read -s RABBITMQ_PASSWD

    VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "{$G} $2 is ...... SUCCESS {$N}" | tee -a $LOG_FILE
    else 
        echo -e "{$R} $2 is ...... FAILURE {$N}" | tee -a $LOG_FILE
        exit 1
    fi
}

    cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
    VALIDATE $? "Copying RabbitMQ repo file"

    dnf install rabbitmq-server -y &>>$LOG_FILE
    VALIDATE $? "Installing RabbitMQ"

    systemctl enable rabbitmq-server &>>$LOG_FILE
    VALIDATE $? "Enabling RabbitMQ"

    systemctl start rabbitmq-server &>>$LOG_FILE
    VALIDATE $? "Starting RabbitMQ"

    rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE

    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))

    echo "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
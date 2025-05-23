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
    
        echo "Please enter root password to setup"
        read -s MYSQL_ROOT_PASSWORD


VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "{$G} $2 is ...... SUCCESS {$N}" | tee -a $LOG_FILE
    else 
        echo -e "{$R} $2 is ...... FAILURE {$N}" | tee -a $LOG_FILE
        exit 1
fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld   &>>$LOG_FILE
VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting MySQL root password"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
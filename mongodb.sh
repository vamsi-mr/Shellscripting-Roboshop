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

    mkdir -p $LOGSFOLDER
    echo "Script executed at : $(date)" | tee -a $LOG_FILE

    if [ $USERID -ne 0 ]
    then    
        echo -e "$R ERROR : Please run with root access $N" | tee -a $LOG_FILE
        exit 1
    else    
        echo -e "$Y You are running with root access $N" | tee -a $LOG_FILE
fi
    

VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is ...... SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "$R $2 is ...... FAILURE $N" | tee -a $LOG_FILE
        exit 1
fi
}

cp mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb.repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongodB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Editing MOngoDB configuration file to enable remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
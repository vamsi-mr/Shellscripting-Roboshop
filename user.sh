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
    

VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "{$G} $2 is ...... SUCCESS {$N}" | tee -a $LOG_FILE
    else 
        echo -e "{$R} $2 is ...... FAILURE {$N}" | tee -a $LOG_FILE
        exit 1
fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating App directory"


id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating Roboshop user"
    else 
        echo -e "{$Y} System user roboshop is already created ..... SKIPPING {$N}"
fi

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading user file"

rm -rf /app/*
cd /app
unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzipping user file"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service file"
 
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reloading"

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enabling user"

systemctl start user &>>$LOG_FILE
VALIDATE $? "Starting user"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
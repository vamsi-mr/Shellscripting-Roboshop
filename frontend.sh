#/bin/bash

USERID=$(id -u)
R="\e[31m"
g="\e[32m"
y="\e[33m"
N="\e[0m"
LOGSFOLDER="/var/log/roboshop"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGSFOLDER/$SCRIPTNAME.log
SCRIPT_DIR=$PWD

    if (USERID -ne 0)
    then    
        echo -e "$R ERROR : Please run with root access $N" | tee -a $LOG_FILE
        exit 1
    else    
        echo -e "$Y You are running with root access $N" | tee -a $LOG_FILE
fi
    
        mkdir -p $LOGSFOLDER
        echo "Script executed at : $(date)" | tee -a $LOG_FILE

VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is ...... SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "$R $2 is ...... FAILURE $N" | tee -a $LOG_FILE
        exit 1
fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOG_FILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"cd /usr/share/nginx/html 

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx"
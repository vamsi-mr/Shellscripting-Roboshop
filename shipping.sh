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

        
    dnf install maven -y
    VALIDATE $? "Installing Maven and Java"

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "Creating App directory"

    id roboshop
        if [ $? -ne 0 ]
        then
            useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
            VALIDATE $? "Creating Roboshop user"
        else 
            echo -e "$Y System user roboshop is already created ..... SKIPPING $N"
    fi

    curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading shipping file"

    rm -rf /app/*
    cd /app
    unzip /tmp/shipping.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping shipping file"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moving and renaming Jar file"

    cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Daemon Realod"

    systemctl enable shipping  &>>$LOG_FILE
    VALIDATE $? "Enabling Shipping"

    systemctl start shipping &>>$LOG_FILE
    VALIDATE $? "Starting Shipping"

    dnf install mysql -y  &>>$LOG_FILE
    VALIDATE $? "Install MySQL"

    mysql_secure_installation -h mysql.ravada.site -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        mysql -h mysql.ravada.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
        mysql -h mysql.ravada.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
        mysql -h mysql.ravada.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
        VALIDATE $? "Loading data into MySQL"
    else
        echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
    fi

    systemctl restart shipping &>>$LOG_FILE
    VALIDATE $? "Restart shipping"

    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))

    echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
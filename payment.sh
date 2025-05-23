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

    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Install Python3 packages"

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


    curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading payment file"

    rm -rf /app/*
    cd /app
    unzip /tmp/payment.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping payment file"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"

    cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
    VALIDATE $? "Copying payment service"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Daemon Reload"

    systemctl enable payment &>>$LOG_FILE
    VALIDATE $? "Enable payment"

    systemctl start payment &>>$LOG_FILE
    VALIDATE $? "Starting payment"

    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))

    echo "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
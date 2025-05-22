#/bin/bash

USERID=$(id -u)
R="\e[31m"
g="\e[32m"
y="\e[33m"
N="\e[0m"
LOGSFOLDER="/var/log/roboshop"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=$LOGSFOLDER/$SCRIPTNAME.log

    if (USERID -ne 0)
    then    
        echo -e "$R ERROR : Please run with root access $N"
        exit 1
    else    
        echo -e "$Y You are running with root access $N"
fi
    
        mkdir -p $LOGSFOLDER
        echo "Script executing at : $(date)"

VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is ...... SUCCESS $N"
    else 
        echo -e "$R $2 is ...... FAILURE $N"
        exit 1
fi
}

cp mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb.repo"

dnf install mongodb-org -y
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod
VALIDATE $? "Enabling MongodB"

systemctl start mongod
VALIDATE$? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MOngoDB configuration file to enable remote connections"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"
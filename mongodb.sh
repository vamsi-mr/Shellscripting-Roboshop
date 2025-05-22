#/bin/bash

USERID=$(id -u)

    if (USERID -ne 0)
    then    
        echo "ERROR : Please run with root access"
        exit 1
    else    
        echo "You are running with root access"
fi
    
VALIDATE () {
    if ($1 eq 0)
        echo "$2 is ...... SUCCESS"
    else 
        echo "$2 is ...... FAILURE"
        exit 1
fi
}

cp mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb.repo"

dnf install mongo-org -y
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod
VALIDATE $? "Enabling MongodB"

systemctl start mongod
VALIDATE$? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MOngoDB configuration file to enable remote connections"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"
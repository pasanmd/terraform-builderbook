#!/bin/bash


#create opt directory
mkdir /opt/builder-book-dev

#install git
yum install git -y
#install npm
yum install npm -y

#install yarn
npm install --global yarn


#clone builderbook repo
git clone https://github.com/async-labs/builderbook.git

cd buidlerbook


sudo bash -c 'cat <<EOF > /opt/builder-book-dev/builderbook/.env
# Used in server/server.js
MONGO_URL=mongo-dev.example.com
MONGO_URL_TEST=mongo-dev.example.com
SESSION_SECRET=mongo-secret

# Used in lib/getRootUrl.js
URL_APP=builderbook.dev.example.com
PRODUCTION_URL_APP=builderbook.dev.example.com

# Used in server/google.js
GOOGLE_CLIENTID=
GOOGLE_CLIENTSECRET=

# Used in server/aws.js
AWS_ACCESSKEYID=dev-accesskeyid
AWS_SECRETACCESSKEY=dev-ecrectaccesskey
AWS_REGION=dev_region

# Used in server/models/User.js
EMAIL_ADDRESS_FROM=pasanmd@gmail.com
EOF'


yarn dev

#!/usr/bin/env  bash

###----> Setup github ssh key
ls -al ~/.ssh
###----> Check if id_rsa exist, if not generate one:
ssh-keygen -t rsa -b 4096 -C "githubemail@domain.com"
eval $(ssh-agent -s)
###----> Check ssh-agent is running then add id_rsa key
ssh-add ~/.ssh/id_rsa
###----> Done

###----> Add SSH to github
cat < ~/.ssh/id_rsa.pub


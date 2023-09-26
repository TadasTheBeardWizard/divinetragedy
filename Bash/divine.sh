# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

sudo apt update && sudo apt upgrade -y 
sudo apt install unzip apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg -y
sudo apt update

#install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

#create random string for password
#VHPW=$(echo $RANDOM | md5sum | head -c 20)

#get stackname created by user data script and update SSM parameter name with this to make it unique
#STACKNAME=$(</tmp/mcParamName.txt)
#PARAMNAME=mcValheimPW-$STACKNAME

#put random string into parameter store as encrypted string value
#aws ssm put-parameter --name $PARAMNAME --value $VHPW --type "SecureString" --overwrite


#install docker and valheim app on docker
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo apt install docker-compose -y
sudo usermod -aG docker $USER
sudo mkdir /usr/games/serverconfig
cd /usr/games/serverconfig
sudo mkdir ./downloads
wget 'https://www.curseforge.com/minecraft/mc-mods/too-many-efficiency-losses/download/2742442'
cd ..
sudo bash -c 'echo "version: \"3.8\"
services:
  mc:
    container_name: divinetragedy
    image: itzg/minecraft-server:java8-multiarch
    ports:
      - 25565:25565
    environment:
      MEMORY: 4G
      CF_API_KEY: ${CF_API_KEY}
      WORLD: "KEBABAI"
      MOTD: "Sveiki atvykę į dokerizuotą pasaulį"
      EULA: "TRUE"
      TYPE: "AUTO_CURSEFORGE"
      VERSION: 1.12.2
      REMOVE_OLD_MODS: "false"
      SERVER_NAME: "Divine Tragedy"
      RCON_PASSWORD: ${RCON_PASSWORD}
      ENFORCE_WHITELIST: "true"
      EXISTING_WHITELIST_FILE: "SYNCHRONIZE"
      WHITELIST: |
        BeardedExpert
        Pheenix_
      CF_PAGE_URL: "https://www.curseforge.com/minecraft/modpacks/divine-journey-2"
      CF_DOWNLOADS_REPO: "/downloads"
    tty: true
    stdin_open: true
    restart: unless-stopped
    volumes:
      - ./minecraft-data:/data
      - ./downloads:/downloads

volumes:
  data:
  downloads:" >> docker-compose.yml'
echo "@reboot root (cd /usr/games/serverconfig/ && docker-compose up)" > /etc/cron.d/awsgameserver
sudo docker-compose up

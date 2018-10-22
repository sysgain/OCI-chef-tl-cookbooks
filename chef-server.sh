#!/bin/sh
sudo apt-get update
# create staging directories
if [ ! -d /downloads ]; then
sudo mkdir /downloads
fi
 # download the Chef server package
if [ ! -f /downloads/chef-server-core_12.16.2_amd64.deb ]; then
echo "Downloading the Chef server package..."
sudo wget -nv -P /downloads wget -nv -P /downloads https://packages.chef.io/files/stable/chef-server/12.17.33/ubuntu/16.04/chef-server-core_12.17.33-1_amd64.deb
fi 
# install Chef server
if [ ! $(which chef-server-ctl) ]; then
echo "Installing Chef server..."
sudo dpkg -i /downloads/chef-server-core_12.17.33-1_amd64.deb
sudo chef-server-ctl reconfigure
 echo "Waiting for services..."
until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 15s; done
while (curl http://localhost:8000/_status) | grep "fail"; do sleep 15s; done
fi
 # create user and organization
if [ ! $(sudo chef-server-ctl user-list | grep chefadmin) ]; then
echo "Creating chefadmin user and orguser organization..."
sudo chef-server-ctl user-create chefadmin Chef Admin admin@test.com Password@1234 --filename /etc/opscode/chefadmin.pem
sudo chef-server-ctl org-create orguser "chef-orguser, Inc." --association_user chefadmin --filename /etc/opscode/orguser-validator.pem
fi
# configure data collection
sudo chef-server-ctl set-secret data_collector token '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'
sudo chef-server-ctl restart nginx
sudo hostname  $(hostname -I)
#sudo chef-server-ctl reconfigure
sudo chef-server-ctl reconfigure
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license
sudo apt-get update
sudo apt-get install -y firewalld
sudo service firewalld stop
echo "Your Chef server is ready!"

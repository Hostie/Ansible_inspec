
apt-get -y install nginx
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

apt-get -y install curl
curl  https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
ln -fs /var/www/test /home/vagrant
 




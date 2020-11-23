# levraud_dylan_TP2
Rendu TP2 - Dylan Levraud B3


# Objectifs du TP

Création et installation d'une machine virtuelle de façon programmatique avec vagrant.
L'appel à l'URL `http://localhost:8080` devra répondre `EHLO world!`




# Installation et configuration Vagrant sur Linux

## Installation du binaire et de Virtualbox

Tout d'abord installons le binaire **Vagrant**, vous trouverez votre version à l'aide de ce lien [ici](https://www.vagrantup.com/downloads)
Il vous faudra l'extraire et l'installer.

Pour faire tourner votre machine, veuillez vous assurer que virtualbox est bien installé sur votre machine. Dans le cas contraire voici la [procédure d'installation](https://doc.ubuntu-fr.org/virtualbox)

Maintenant que tout est installé il vous faut créer un dossier qui acceuillera tous les fichiers :

```mkdir nom_du_fichier```


## Configuration du Vagrantfile

Le Vagrantfile vous permet de configurer votre machine virtuelle. Il se trouve à la racine de votre dossier. Vous pourrez modifier et reconfigurer votre machine à votre guise en modifiant le fichier *Vagrantfile*.

Le fichier final prend cette forme :

```                              
Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "debian"
    vb.cpus = 2
    vb.memory = 2048
  end
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 8080
end
```



### Detail du fichier

```config.vm.box = "debian/buster64"```

Correspond à la box que nous allons utiliser pour ce TP, ici une debian. Vous pouvez retrouver les boxs à cette [adresse](https://app.vagrantup.com/boxes/search) pour prendre celle que vous souhaitez. 

 ```config.vm.provider "virtualbox" do |vb|
    vb.name = "debian"
    vb.cpus = 2
    vb.memory = 2048
  end
```
  
Ici on retrouve la configuration pour la virtualisation. On y trouve le nombre de cpu alloués à la machine, aini que son nom et la taille de sa mémoire RAM.

```config.vm.provision :shell, path: "bootstrap.sh"```

La ligne de provision indique à Vagrant d'utiliser le provisioner de shell pour configurer la machine, avec le fichier bootstrap.sh que l'on créera ci-après.

```config.vm.network :forwarded_port, guest: 80, host: 8080```

Ici on retrouve le port fowarding du port 80 qui se situe sur la VM et le port 8080 sur votre poste. Ceci permettra d'accéder au localhost du serveur nginx pour récupérer la phrase depuis votre poste.

## Configuration bootstrap.sh

Le fichier boostrap.sh est un script shell qui va être appelé pour la configuration de la VM. Ce fichier peut vous permettre d'installer tout ce que vous souhaitez (services, créer des liens, installation de paquets etc)

Le nôtre prend la forme suivante 

```
apt-get -y install nginx
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

apt-get -y install curl
curl  https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
ln -fs /var/www/test /home/vagrant
```

Ici on installe NGINX pour le serveur web, et curl pour récuperer le contenu du site plus simplement en une commande et l'outil inspec qui nous permettra de checker si notre configuration est bonne. On crée également les liens nécessaires pour acceuillir notre dossier html, qui remplacera celui de la VM.


## Dossier html et fichier index.html

Il vous faudra créer un dossier html à la racine du dossier vagrant ainsi que le fichier index.html 

```
mkdir html
touch html/index.html
```
Vous pouvez modifier votre fichier html pour y ajouter la phrase demandée : `EHLO world!`


## Le dossier test et l'outil Inspec

L'outil Inspec permet de checker tous les paramètres que nous souhaitons vérifier. Le fichier test.rb est un fichier écrit en ruby qui nous permettra à l'aide de quelques lignes de code de checker notre configuration. Je vous renvoie à la documentation Ruby si vous souhaitez tester plus de chose.


Notre fichier prend la forme suivante :

Nous vérifions que le port 80 doit écouter, que le package nginx est bien installé, que la vm est bien une debian, que notre localhost renvoie bien notre phrase, et que le port ssh est bien le port 22

```
describe port(80) do
  it { should be_listening }
end

describe port(8080) do
  it { should_not be_listening }
end

describe package('nginx') do
  it { should be_installed }
end

describe os.family do
  it { should eq 'debian' }
end

describe http('http://127.0.0.1:80') do
  its('body') { should include 'EHLO world !' }
end

describe ssh_config do
  its('port') { should eq '22' }
end
```

Par exemple si je veux tester que le package nginx est bien installé je dois renseigner le code suivant :

```  describe package('nginx') do
  it { should be_installed }
end
```

## Lancement de la VM et commandes Vagrant

Maintenant que tout est configuré nous allons pouvoir lancer notre VM. A la racine du dossier :

```
vagrant up
```

Cette commande lancera l'installation et la configuration de votre vm.

``` 
vagrant reload 
```

Permet de redemarrer votre machine


```
vagrant provision

vagrant reload --provision
```

Permet de réapprovisionner votre Vm avec vos fichiers de configuration. Directement sur la VM qui tourne ou en la redémarrant. 

```
vagrant ssh
```
Permet de vous connecter à la machine


## Vérification de la consigne

Sur votre machine en *local* après avoir demarrez votre machine virtuelld tapez:

```
curl http://localhost:8080
```
Cette commande doit vous retourner 

``` EHLO World ! ```


### BONUS : Inspec

Nous allons vérifier maintenant notre configuration. 

```
vagrant ssh
```
Nous nous connectons à la machine virtuelle 

```
inspec exec test/test.rb 
```

La commande devra vous renvoyer la bonne configuration de votre VM

```
Profile: tests from test/test.rb (tests from test.test.rb)
Version: (not specified)
Target:  local://

  Port 80
     ✔  is expected to be listening
  Port 8080
     ✔  is expected not to be listening
  System Package nginx
     ✔  is expected to be installed
  debian
     ✔  is expected to eq "debian"
  HTTP GET on http://127.0.0.1:80
     ✔  body is expected to include "EHLO world !"
  SSH Configuration
     ✔  port is expected to eq "22"

Test Summary: 6 successful, 0 failures, 0 skipped
```

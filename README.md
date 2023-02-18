 # AJK Assignment Deploy Laravel In AWS EC2
Kelompok 6:
- Alfa Fakhrur Rizal Zaini (5025211214)
- M Rafif Tri Risqullah (5025211009)
- Nabila A'idah Diani (5025211032)

## Create EC2 Instance using Terraform
Create 3 files to configure EC2 instance:
- main.tf (For main configuration)
- variables.tf (For Variables we use at Main)
- secretVar.tfvars (Used For Secret Variables)

## Set Provider, Instance, And Security Group
set aws as provider, region, secret, and key
```terraform
provider "aws" {
    region = var.aws_region
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_key

    #both secret key and access key value put inside secretvar.tfvars
}
```
security resource is use to set security configuration, and firewall. Here we set 4 port to be opened.
```terraform
resource "aws_security_group" "instance_security_group" {
    name = var.security_group
    description = "Allow 4 port (443,80,22,3306) to be accessed"
    
    #for each port inbound
    ingress {
        from_port = (80 / 443 / 22/ 3306)
        to_port = (80 / 443 / 22/ 3306)
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #for outbound
    engress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}
```
Next set up for EC2 instance configuration, AMI ID, instance_type, key_pair, security_group, tags, and block size
```terraform
resource "aws_instance" "Learn-Terraform" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair
  vpc_security_group_ids = ["${aws_security_group.instance_security_group.id}"]
  tags = {
    Name = var.tag_name
  }

  root_block_device {
    volume_size = 8
  }
}
```

## Variables For Configruation
set variables we would use in main.tf inside variables.tf
```terraform
variable "AWS_SECRET_ACCESS_KEY" {
    type = string
    default = null
}
variable "AWS_ACCESS_KEY_ID" {
    type = string
    default = null
}
variable "aws_region" {
    description = "Region for AWS EC2 instances"
    default = "ap-southeast-1"
}

variable "instance_type" {
    description = "instance type for EC2 instance"
    default = "t2.micro"
}

variable "tag_name" {
    description = "Tag name for EC2 intance"
    default = "EC2 Instance"
}

variable "ami_id"{
    description = "AMI instance ID"
    default = "ami-082b1f4237bd816a1"
}

variable "key_pair"{
    description = "Key to access Instance via ssh"
    default = null
}

variable "security_group"{
    description = "Security Group"
    default = "instance-security-group"
}
```
## Fill secretVar Values
Fill secret values in secretvar.tfvars, fill it with your access key id and secret access key
```terraform
AWS_ACCESS_KEY_ID = {aws_access_key_id}
AWS_SECRET_ACCESS_KEY = {aws_secret_access_key}
key_pair = {Key_Pair}
```
## Initialization, Plan, and Apply
Run **terraform init** to initialize terraform configuration and download provider modules
```sh
terraform init
```
Run **terraform validate** to check our code validation
```sh
terraform validate
```
run **terraform plan**, so we could see comparation report, about modifications, added, and destroyed resources. It's preferable to run this command before we apply the configuration. Don't forget to use ``--var-file=secretvar.tfvars`` to apply out secretvar in the configuration comparing
```sh
terraform plan --var-file=secretvar.tfvars
```
If you think the configuration is ready to be created, run **terraform apply** to apply all configuration and use ``--var-file=secretvar.tfvars`` flag to use our secret var
```sh
terraform apply --var-file=secretvar.tfvars
```
With all the step we've done above, we've done creating new instance using terraform. Next, let's set up for laravel deployment in our EC2 instance.

## Deploying Laravel with Nginx Configuration
This section will discuss the steps to deploy laravel app with nginx configuration on the ubuntu server.

## Shell Provisioning
on the root project directory, create a new .sh file, called 'command.sh'.

```
# Update installed dependencies
sudo apt-get update -y

# Install dependencies and add PHP8.0 repository
sudo apt-get install  ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y

# Install nginx
sudo apt-get install nginx -y

# Set firewall permission for port 22, 80, and 443
echo "y" | sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 443
sudo ufw allow 80
sudo ufw allow 22

# Install PHP8.0 version to run the Laravel Project
sudo apt-get update -y
sudo apt-get install php8.0-common php8.0-cli -y

# install PHP package
sudo apt-get install php8.0-mbstring php8.0-xml unzip composer -y
sudo apt-get install php8.0-curl php8.0-mysql php8.0-fpm -y

# install MYSQL
sudo apt-get install mysql-server -y

# Set MYSQL password
sudo apt-get install debconf-utils -y
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

# Nginx config
sudo cp /var/www/config/example.conf /etc/nginx/sites-available/example.conf

# Copy to sites-enabled directory
sudo ln -s /etc/nginx/sites-available/example.conf /etc/nginx/sites-enabled
sudo service nginx restart
```

## Clone the laravel template application
```
git clone https://gitlab.com/kuuhaku86/web-penugasan-individu.git
``` 

also, give permission to var/www so the Laravel App can write its log.
```
sudo chown -R www-data:www-data /var/www/html
```

## Configurate the example.conf as below
```
server {
        listen 80;
        root /var/www/web-penugasan-individu/public;
        index index.php index.html index.htm index.nginx-debian.html;
        
        # Change this later to the DNS when creating SSL via certbot
        server_name localhost;

        location / {
                try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
}
```
don't forget to change the public directory path, where it may differs based on our project's directory


## Create a New Database
In this step, we will create database and customize our USER and PASSWORD based on the fixed team list.
```
sudo mysql -u root -p

CREATE DATABASE laravel;
CREATE USER 'kelompok6'@'%' IDENTIFIED BY 'kelompok6';
GRANT ALL PRIVILEGES ON laravel.* TO 'kelompok6'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

## Editing the Environment for the Laravel App
Copy the example environment, and then edit the env
```
sudo cp .env.example .env
sudo nano /var/www/web-penugasan-individu/.env

# edit env.
APP_NAME=Laravel
APP_ENV=local
APP_KEY=			//generate later using the php artisan key:generate
APP_DEBUG=true			//set true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_LEVEL=debug
LOG_DEBUG=true			//set true

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=kelompok6		//according to your team number
DB_PASSWORD=kelompok6		//according to your team number
```

## Synchronizing the composer.lock file with depedencies updates
Use the sudo (superuser do) since we will need permission for write
```
sudo composer install
sudo composer update

# Upgrade Composer
sudo which composer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
```

## Generating APP_KEY and DATABASE Migration
```
sudo php artisan key:generate
sudo php artisan migrate
sudo service nginx reload
```

## Get Domain Name System
Buy a DNS we will use for our application
u can buy it in [niagahoster](niagahoster.co.id)
for this project we use ``.site`` domain.
[our project site](https://tugas.ajkkelompokzaenab.site/)

## DNS SECTION
Next, set records for dns both in aws route53 and dns record management in niagahoster.
set dns target to EC2 instance public_ip, therefore you'll able to access your site via port 80

## CERTBOT SECTION
To ahve access from https protocol, set up certificate using certbot
### Install snapd
```sh
sudo apt install snapd
```
### Ensure our snapd is up to date
```sh
sudo snap install core; sudo snap refresh core
```
### Remove certbot-auto and any Certbot OS packages
```sh
sudo apt-get remove certbot
```
### install certbot
```sh
sudo snap install --classic certbot
```
### Prepare the Certbot command
```sh
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```
### Choose how you'd like to run Certbot
```sh
sudo certbot --nginx
```
if you got **server_name** error in this section, make sure you have set your server_name in ``example.conf``
with our dns instead of localhost
### Test automatic renewal
```sh
sudo certbot renew --dry-run
```
for more detail, you can go to [this site](https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal)

Now you can access via https protocol
## CRONTAB SECTION
First, install cron on linux to schedule the python script
### Install cron
```sh
sudo apt-get update
```
```sh
sudo apt-get -y install cron
```
### Edit cron
```sh
sudo nano /etc/crontab
```
### Set up cron schedule
```sh
* * * * * /path/to/file.py
```
### Connect webserver to cron schedule
Use powershell to connect cron schedule with webserver by generating key from aws and decrypt key
```sh
$path = ".\notes-api-webserver.pem"
```
Reset to remove explicit permissions
```sh
icacls.exe $path /reset
```
Give current user explicit read-permission
```sh
icacls.exe $path /GRANT:R "$($env:USERNAME):(R)"
```
Disable inheritance and remove inherited permissions
```sh
icacls.exe $path /inheritance:r
```

Then log in to ssh using the key and Public IP


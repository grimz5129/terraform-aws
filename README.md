# terraform-aws
### This is the terraform script to create a tier-2 infrastructure
![image](https://user-images.githubusercontent.com/59632166/150206886-eddc08a1-305c-46d5-9b29-642f37d24b3b.png)


You need to have terraform installed

run terraform init to initialise the workspace

#### terraform commands

* terraform validate: checks if the main.tf file configuration is valid.
* terraform plan: creates a overlook of what will be created when the script is run.
* terraform apply: runs the script and creates the infrastructure.
* terraform destroy: shutsdown and terminates all running comonents.

#### Add access and secret key to aws-vault

* aws-vault add sparta_temp
* Enter access key
* Enter secret key
* Enter region = eu-west-1
* Leave output empty

#### aws commands

* aws-vault remove sparta_temp
* aws-vault exec sparta_temp -- terraform plan

#### Docker Commands
* sudo apt update
* sudo apt install docker.io
* sudo usermod -aG docker ${USER}
* exit ssh session
* reconnect ssh session
* docker run -p 8080:8080 --mount type=bind,source=/home/ubuntu/application.properties,target=/application.properties grimz5129/sakilarestapi2

#### Update MYSQL DB
* ssh into the DB server
* docker cp sakila-db/sakila-data.sql  <container_name>:/
* docker exec -it <mySQL_Container_ID> bash
* mysql -u root -proot sakila < sakila-db/sakila-data.sql

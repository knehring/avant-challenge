# Avant Challenge

This is a basic rails application running with a postgresql database. It is built inside of a docker container and deployed using docker-compose.
The infrastructure is described inside of the terraform.tf file. 

## Prerequisites
* AWS Profile
* AWS Region (us-east-1)

## How to run
Simply run `terraform apply` you will be prompted to enter your AWS profile. 
At the end of the terrform apply run, it will output the dns name for the application. 
Go to the url provided.

## Caveats
I have included a public and private key that was generated specifically for this application. I would normally not store a private key within a repo, but 
for challenge purposes I have done so.

I have also created a VPC with a cidr of 10.0.0.0 and a subnet of 10.0.200.0, hopefully this will not collide with any previously created VPC's / Subnets

## Application Details
This application is very basic. Data is stored inside of a postgresql database.

### Routes
* /resume/new -- create a new resume
* /resume/:id -- view specific resume
* /resume/all -- view list of all created resumes

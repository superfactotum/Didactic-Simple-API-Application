# Didactic-Simple-API-Application


The following code has been written only for didactic purposes.
The code is not deplayable in a production environment!!!

This code is not structured to be run in different environments and many production features are just missing.

Also, it has not even been tested, as an AWS account would be necessary to do that.

It may be useful just to suggest ideas on how a production system could be created.


# Description


Application Overview:

The application is a simple "Hello World" style Python web service built with Flask. It exposes two HTTP APIs:

- PUT /hello/<username>: Inserts or updates a user's name and date of birth in a PostgreSQL database. 
  It validates that the username contains only letters and the date of birth is before today.
- GET /hello/<username>: Retrieves a user's record and returns a birthday message. 
  If it's the user's birthday, it says "Happy birthday!". Otherwise, it indicates how many days are left until their next birthday.


Components & Architecture:

Application Code (app.py): 
- Python Flask application defining the API endpoints, business logic (date calculations, message formatting), and database interactions.
- Database (schema.sql, PostgreSQL): A PostgreSQL database stores user information (username, date_of_birth) in a users table.
- WSGI Server (Gunicorn): Gunicorn is used as a production-ready WSGI HTTP server to run the Flask application. It's configured via a systemd service.

Virtual Machine (api_app_vm): 
- An AWS EC2 instance hosts the application, database, and Gunicorn.

Networking (AWS VPC, Subnet, EIP, Security Group):
- A custom VPC (app-vpc) provides network isolation.
- A public subnet (app-public-subnet) allows the VM to be accessible from the internet.
- An Elastic IP (api-app-eip) provides a static public IP address for the VM.
- A Security Group (api-app-sg) acts as a firewall, allowing inbound traffic on port 22 (SSH) and port 5000 (for the application).

Infrastructure as Code (Terraform - main.tf, variables.tf, outputs.tf): 
- Terraform is used to define and provision the AWS cloud infrastructure (VPC, subnet, EC2 instance, EIP, security group).

Configuration Management & Deployment (Ansible - playbook.yml, roles): 
- Ansible automates the setup and deployment of the application onto the provisioned EC2 instance. It handles:
- Installing system dependencies (Python, pip, PostgreSQL client libraries).
- Creating an OS user for the application.
- Setting up a Python virtual environment.
- Installing Python application dependencies (Flask, psycopg2-binary, Gunicorn) from requirements.txt.
- Copying the application source code.
- Applying the database schema.
- Configuring and enabling a systemd service (hello_app.service) to manage the Gunicorn process.

Installation & Launch Process:

Provision Infrastructure (Terraform):

take care of the needed credential variables

- terraform init
- terraform plan
- terraform apply


Run the Ansible playbook: 

- ansible-playbook -i inventory.ini --key keyfile 


Access the Application:


You can access the APIs using the public IP address of the VM and port 5000 (as configured for Gunicorn). For example:

- PUT http://<api_app_vm_public_ip>:5000/hello/yourname with JSON body {"dateOfBirth": "YYYY-MM-DD"}
- GET http://<api_app_vm_public_ip>:5000/hello/yourname

An URL alias might be needed according to the security requirements

Deployment of 3 tier architecture in azure using terraform.

What is three-tier architecture?

Three-tier architecture in Azure includes Web tier, Application tier and Database Tier. This template follows standard best practices for deploying Virtual Machine Scale Set for Web Tier and App Tier and SQL Server for Database Tier.

What is terraform?

Terraform is an open-source infrastructure as code software tool created by HashiCorp. Users define and provision data center infrastructure using a declarative configuration language known as HashiCorp Configuration Language, or optionally JSON.
Installation

    Terraform

Pre requisite to build the solution

    Azure subscription.
    Azure service principle
    Terraform open source installed , azure CLI or Powershell

Architecture:

![image](https://user-images.githubusercontent.com/58088308/121925952-0edcc700-cd5b-11eb-8bce-e84f2a4237e7.png)




Components used in this template:

1) Application Gateway is layer 7 web traffic load balancer that enables you to manage traffic to your web applications. Application gatway provide URL-based routing, multi-site routing, redirect rules, Cookie-based session affinity, SSL termination and Web Application Firewall (WAF) features. This makes it more secure and preferable for web servers which are accessed via public ip.

2) Azure Load Balancer is a Layer-4 (TCP, UDP) load balancer that provides high availability by distributing incoming traffic among healthy VMs. A load balancer health probe monitors a given port on each VM and only distributes traffic to an operational VM.

3) Web Layer is a Azure Linux Virtual Machines Scaleset with availability zones. All the incoming traffic will be termiated on Application gateway then it will redirect to Web Tier Vmss.

4) App Layer is a Azure Virtual Machine Scaleset with availability zones. Traffic form Web Tier will terminate on Load Balancer and then it will be redirected to App Tier Vmss.

5) Database Layer Azure PASS database with elastic pool. Elastic pools are a simple, cost-effective solution for managing and scaling multiple databases that have varying usage demands. Elastic Pool solve this problem of cost and performance by ensuring that databases get the performance resources they need when they need it. They provide a simple resource allocation mechanism within a predictable budget. This soultion is very flexible to Auto Scale, adding/removing resource as per the use.

6) Azure Key Vault is a cloud service for securely storing and accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, or cryptographic keys. In this template we are storing database password and vmss password in Azure Key Vault.

7) Log Analytics is a Azure tool used to edit and run log queries with data in Azure Monitor Logs. We are using Log Analytics workspace for collecting data from application gateway.

8) Azure Bastion is a PAAS service for secure and seamless SSH/RDP connectivity to your Vms directly from Azure Portal over SSL.


Terraform Module: A Terraform module is a set of Terraform configuration files in a single directory. Even a simple configuration consisting of a single directory with one or more .tf files is a module. Or we can say Module is a container for multiple resources that are used together.

For this deployment we have created 10 modules as explained below.
Terraform Module structure:-

```bash

├── main.tf                   // The root module which calls sub modules sequentially for terraform resources provisoning.
├── variables.tf              // It contain the declarations for variables.
├── terraform.tfvars          // The file to pass the terraform variables values.
├── terraform.tf              // It contain config for remote backend to store statefile.
    ├── modules               // Directory contains all sub modules to provision all components of 3 tier architecture
        ├──network            // Module to create network (vnet and subnet)
           ├── main.tf        // Primary configuration to provision network resources.
           ├── variables.tf   // It contains required variables to create network resources.
           ├── outputs.tf     // It expose the required attribute of network resources for reference of other resource.
        ├──database           // Module to create database with elastic pool to form data layer of architecture
           ├── main.tf        // Primary configuration to provision database resources(db server, elastic pool, database ).
           ├── variables.tf   // It contains required variables to create database resources.
        ├──compute            // Module to create Vmss
           ├── main.tf        // Primary configuration to provision linux VMss, NIC, Availability zone etc.
           ├── variables.tf   // It contains required variables to create Compute resources.
           ├── outputs.tf     // It expose the required attribute of compute resources.
        ├──bastion            // Module to create Azure Bastion
           ├── main.tf        // Primary configuration to provision Azure Bastion.
           ├── variables.tf   // It contains required variables to create Azure Bastion resources.   
        ├──autoscale          // Module to create Autoscalling
           ├── main.tf        // Primary configuration to provision Autoscalling.
           ├── variables.tf   // It contains required variables to create Autoscalling resources.
        ├──loganalytics       // Module to create loganalytics workspace and solution
           ├── main.tf        // Primary configuration to provision loganalytics
           ├── variables.tf   // It contains required variables to create loganalytics.
           ├── outputs.tf     // It expose the required attribute of loganalytics resources.
        ├──appgateway         // Module to create application gatway to securly connect and provide http routing for web tier.
           ├── main.tf        // Primary configuration to provision application gateway resources.
           ├── diagnostic.tf  // Configuration to integrate Application gateway with Azure Monitor diagnostic to collect logs.
           ├── variables.tf   // It contains required variables to create and configure application gateway.
           ├── outputs.tf     // It expose the required attribute of application gateway.
        ├──loadbalancer       // Module to create Load balancer.
           ├── main.tf        // Primary configuration to provision Load Balancer resources.
           ├── variables.tf   // It contains required variables to create and condifugre Load Balancer. 
           ├── outputs.tf     // It expose the required attribute of Load Balancer.  
        ├──keyvault           // Module to store database password, virtual machine scaleset login password and key in azure key vault secrets 
           ├── main.tf        // Primary configuration to create secrets for storing password and ssl in key vault.
           ├── variables.tf   // It contains required variables to create and configure secrets in key vault.
           ├── outputs.tf     // It expose the required attribute of Key vault.
        ├──securitygroup      // Module to create Security Group.
           ├── main.tf        // Primary configuration to provision Security Group.
           ├── variables.tf   // It contains required variables to create and configure Security Group. 

```             

Deployment Steps:-


Step 0 terraform init

used to initialize a working directory containing Terraform configuration files


Step 1 terraform validate

validates the configuration files in a directory, referring only to the configuration and not accessing any remote services such as remote state, provider APIs, etc

Step 2 terraform plan 

This create an execution plan.

Step 3 terraform apply

This apply the changes required to reach the desired state of the configuration.

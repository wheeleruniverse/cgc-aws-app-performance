# Terraform Infrastructure (IaC)

---
## About

### Commands
* **terraform apply -auto-approve**
  
Used to apply changes to the tracked environment. (Billing Starts)

https://www.terraform.io/docs/cli/commands/apply.html

`auto-approve` used to automatically approve the changes that will be made 

* **terraform destroy -auto-approve**

Used to destroy changes to the tracked environment. (Billing Stops)

https://www.terraform.io/docs/cli/commands/destroy.html

`auto-approve` used to automatically approve the changes that will be made 

* **terraform fmt**

Used to format Terraform template files.

https://www.terraform.io/docs/cli/commands/fmt.html

* **terraform init**

Used to initialize providers and Terraform dependencies for provided template files.

https://www.terraform.io/docs/cli/commands/init.html

* **terraform plan**

Used to plan changes that against the tracked environment.

https://www.terraform.io/docs/cli/commands/plan.html

### Files
* **.terraform.lock.hcl** <span style="color:green">+ version control</span>
  
Used to track Terraform provider and dependencies.

https://www.terraform.io/docs/language/dependency-lock.html

* **main.tf** <span style="color:green">+ version control</span>

Used to define resources that Terraform should create. The filename doesn't matter as Terraform will pick all files with 
the `.tf` extension. Additionally, templates can be divided into any number of `.tf` files and Terraform will use them as if 
they were one file. If there is a need to separate resources then separate directories should be created so the 
resources and state can be managed independently. 

https://www.terraform.io/docs/language/files/index.html

* **terraform.tfstate** <span style="color:red">- version control</span>

Used to track resources state from the provider(s) used. If this is lost then Terraform will not be able to properly 
manage the resources. 

https://www.terraform.io/docs/language/state/index.html

* **terraform.tfvars** <span style="color:red">- version control</span>

Used to provide variables to templates. Sometimes these variables are sensitive values that are not safe to store within 
the template directly. For these reasons the `.tfvars` files should be excluded from version control. If the name of the 
variable file is `terraform.tfvars` then it will be picked automatically. Other filenames can be used, but the user will 
need to supply the variable file or values when attempting to apply the template.

https://www.terraform.io/docs/language/values/variables.html

---
## Networking Infrastructure

Terraform: 
* vpc/.terraform.lock.hcl
* vpc/main.tf
* vpc/terraform.tfstate

---
## Application Infrastructure

Terraform File:  
* app/.terraform.lock.hcl
* app/main.tf
* app/terraform.tfstate
* app/terraform.tfvars
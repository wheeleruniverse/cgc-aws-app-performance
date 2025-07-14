# AWS Application Performance Enhancement

This repository contains a solution for the \#CloudGuruChallenge focused on improving the performance of a Python application by integrating Amazon ElastiCache for Redis. This project demonstrates practical skills in cloud infrastructure deployment, application optimization, and the use of Infrastructure as Code (IaC) with Terraform.

## Overview

The primary goal of this project is to address application performance bottlenecks caused by frequent database queries. The solution implements a caching layer using Amazon ElastiCache (Redis) to reduce direct database hits, thereby significantly improving response times and overall application efficiency. The project is a response to a challenge that involved a deliberately slow Python Flask application backed by a PostgreSQL database.

## Architecture

The solution's architecture is designed to separate network and application components for better organization and security.

### Network Architecture

The network components typically include:

  * **Amazon VPC (Virtual Private Cloud):** Provides a logically isolated virtual network where AWS resources are launched.
  * **Public and Private Subnets:** Segregates resources based on their accessibility to the internet. Public subnets host internet-facing resources, while private subnets host internal resources like databases and application servers.
  * **Route Tables:** Control network traffic routing within the VPC.
  * **Internet Gateway:** Allows communication between the VPC and the internet.
  * **Security Groups:** Act as virtual firewalls to control inbound and outbound traffic for instances.

### Application Architecture

The application components typically include:

  * **Amazon EC2 Instance:** Hosts the Python Flask application.
  * **Amazon RDS for PostgreSQL:** The relational database storing application data.
  * **Amazon ElastiCache for Redis:** The in-memory data store used as a caching layer to store frequently accessed database query results.

The Python application is configured to first check the Redis cache for requested data. If the data is found in the cache (cache hit), it is served directly. If not (cache miss), the application queries the PostgreSQL database, retrieves the data, and then stores it in the Redis cache for future requests before serving it to the user.

## Technologies Used

  * **Programming Language:** Python (3.6+)
  * **Web Framework:** Flask
  * **Database Connector:** `psycopg2`
  * **Configuration Management:** `configparser`
  * **Caching Client:** `redis`
  * **Application Server:** Gunicorn (for production-ready deployment)
  * **Infrastructure as Code (IaC):** Terraform
  * **Cloud Platform:** Amazon Web Services (AWS)
      * Amazon EC2
      * Amazon RDS (PostgreSQL)
      * Amazon ElastiCache (Redis)
      * Amazon VPC

## Setup and Deployment

The infrastructure for this project is defined and deployed using Terraform.

### Prerequisites

  * An AWS Free Tier account.
  * Python 3.6 or higher installed.
  * Terraform installed.
  * AWS CLI configured with appropriate credentials.

### Deployment Steps

1.  **Clone the Repository:**

    ```bash
    git clone https://github.com/wheeleruniverse/cgc-aws-app-performance.git
    cd cgc-aws-app-performance
    ```

2.  **Configure Terraform:**
    Navigate to the `terraform` directory and initialize Terraform.

    ```bash
    cd terraform
    terraform init
    ```

3.  **Deploy AWS Infrastructure:**
    Apply the Terraform configuration to provision the VPC, subnets, security groups, RDS PostgreSQL database, EC2 instance, and ElastiCache Redis cluster.

    ```bash
    terraform apply
    ```

    Review the plan and confirm the deployment by typing `yes`.

4.  **Application Setup on EC2:**
    Once the EC2 instance is provisioned, connect to it (e.g., via SSH).

      * Install necessary Python packages:
        ```bash
        pip install Flask psycopg2-binary redis gunicorn
        ```
      * Copy the application code from the `app` directory to the EC2 instance.
      * Configure the application to connect to your deployed RDS PostgreSQL database and ElastiCache Redis cluster using their respective endpoints and credentials. Ensure the security groups allow traffic between the EC2 instance, RDS, and ElastiCache.

5.  **Run the Application:**
    Start the Flask application using Gunicorn.

    ```bash
    gunicorn -w 4 -b 0.0.0.0:8000 app:app
    ```

    (Adjust `app:app` based on your main application file and Flask app instance name.)

## Application Functionality

The Python Flask application serves as a simple web interface that interacts with a PostgreSQL database. Initially, the database queries are slow. The core functionality improvement lies in the integration of Redis caching:

  * **Cache-Aside Pattern:** Before querying the database, the application first checks if the requested data is present in the Redis cache.
  * **Cache Hit:** If data is found in Redis, it is immediately returned, bypassing the slower database query.
  * **Cache Miss:** If data is not in Redis, the application queries the PostgreSQL database. Once retrieved, the data is stored in Redis for subsequent requests and then returned to the user. This ensures that frequently accessed data is quickly available from the cache.

## Performance Improvement

By implementing the ElastiCache Redis layer, the application significantly reduces the latency associated with database reads. This leads to a substantial improvement in page load times, especially for frequently accessed data, enhancing the overall user experience. Anecdotal evidence from similar challenges indicates a reduction in page load times from several seconds to less than one second after cache implementation.

## Resources

  * [\#CloudGuruChallenge: Improve Application Performance using Amazon ElastiCache](https://www.pluralsight.com/resources/blog/cloud/cloudguruchallenge-improve-application-performance-using-amazon-elasticache)
  * [AWS App Performance](https://dev.to/wheeleruniverse/jun-21-cloudguruchallenge-2k11)

## License

This project is licensed under the MIT License.

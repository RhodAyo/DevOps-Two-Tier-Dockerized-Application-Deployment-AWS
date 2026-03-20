# Architecture Overview

This project deploys a two-tier WordPress application using Docker on an EC2 instance, with persistent storage using an EBS volume.

## System Flow

User → EC2 Instance → Docker → WordPress Container → MySQL Container → EBS Volume

A user accesses the application through a web browser using the EC2 public IP. The request reaches the EC2 instance on port 80. Docker routes this request to the WordPress container, which serves the web application. WordPress communicates with the MySQL container to retrieve and store data. The MySQL container stores its data on an attached EBS volume to ensure persistence.

---

## Why Use EBS for MySQL Data?

An EBS volume is used to persist MySQL data outside the container.

Containers are ephemeral by design, meaning they can be stopped, destroyed, and recreated at any time. If MySQL stored data only inside the container, all data would be lost when the container is destroyed.

By mounting the EBS volume to `/mnt/mysql-data`, the database files are stored outside the container. This ensures that even if the container is deleted or recreated, the data remains intact.

Without EBS:
- Database data would be lost on container restart or deletion
- WordPress would lose all content (posts, users, settings)

---

## Security Group Configuration

The following ports were opened:

- Port 22 (SSH): Allows remote access to the EC2 instance for administration
- Port 80 (HTTP): Allows users to access the WordPress application

### Security Risks

- Port 22 is open to `0.0.0.0/0`, which means anyone can attempt to SSH into the server. This is a security risk and should ideally be restricted to specific IP addresses.
- No HTTPS (port 443) is configured, so data is transmitted in plain text.
- Database is not exposed publicly, which is good practice.

---

## Failure Scenario: EC2 Crash

If the EC2 instance crashes:

### What survives:
- MySQL data stored on the EBS volume
- Docker images (if stored remotely like Docker Hub)

### What is lost:
- Running containers
- Any data stored inside containers (except MySQL data on EBS)
- Application state not persisted externally

To recover:
- Launch a new EC2 instance
- Reattach the EBS volume
- Redeploy containers using docker-compose

---

## Scaling Considerations (100x Users)

To handle more users, several improvements would be needed:

- Use a Load Balancer to distribute traffic across multiple EC2 instances
- Separate WordPress and MySQL onto different servers
- Use Amazon RDS instead of running MySQL in a container
- Add caching (e.g., Redis) to reduce database load
- Enable auto-scaling for EC2 instances
- Use a CDN (e.g., CloudFront) to serve static content faster

At this stage, I am not fully confident in implementing all these, but I understand that scaling involves distributing load and reducing bottlenecks.

---

## Reflection

This architecture is simple and suitable for learning and small-scale deployments. It demonstrates key DevOps concepts such as containerization, infrastructure automation, and persistent storage. However, for production systems, more focus would be needed on security, scalability, and fault tolerance.
---
title: Tiers of compliance
author: Patrick Deutsch
type: [main]
date: 2023-05-01T16:22:46-06:00
lastmod: 2023-05-01T16:30:05-06:00
url: /2023/05/01/tiers-of-compliance/
excerpt: Tiers of compliance
categories:
  -  aws
  -  hugo
  -  cloudfront
  -  route53
  -  s3
tags:
  -  aws
  -  cloudfront
  -  route53
  -  certificates
  -  s3
  -  terrafrom
draft: false
---
# Regulatory Compliance in the Cloud

## FISMA Compliance
| Control Area            | FISMA Low                                                                 | FISMA Moderate                                                                                   | FISMA High                                                                                      |
|-------------------------|----------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| Identity & Access Management  | - Basic IAM policies<br>- MFA for privileged users<br>- Regular access reviews. | - More stringent IAM policies<br>- MFA for all users<br>- Role-based access control<br>- Regular access audits<br>- Temporary credentials for short-term access | - Enhanced user monitoring<br>- Continuous access auditing<br>- Additional access restrictions<br>- Session duration limitations<br>- Just-In-Time (JIT) access |
| Data Encryption         | - Encryption at rest (KMS, S3, EBS)<br>- Encryption in transit (TLS)      | - More stringent encryption key management<br>- Automated key rotation<br>- Dedicated KMS Customer Master Keys (CMKs) | - Enhanced encryption algorithms<br>- Hardware security modules (HSM) integration<br>- Stronger key management policies<br>- Key access and usage logging |
| Network Security        | - Basic VPC setup<br>- Security groups<br>- Network ACLs                  | - Enhanced VPC isolation<br>- WAF<br>- Network traffic monitoring<br>- Intrusion detection<br>- VPN or Direct Connect for hybrid environments | - Advanced network protection<br>- Anomaly detection<br>- More comprehensive traffic analysis<br>- Micro-segmentation of network resources<br>- PrivateLink for service access |
| Logging & Monitoring    | - Basic CloudTrail and CloudWatch setup<br>- Log storage and retention | - Extended logging (S3, Lambda, RDS, etc.)<br>- More granular monitoring<br>- Regular audits<br>- AWS Config for resource tracking | - Real-time continuous monitoring<br>- Advanced analytics (Amazon Elasticsearch, Kinesis)<br>- Automated response capabilities (Lambda, Step Functions)<br>- Centralized logging across accounts and regions |
| Patch Management & Vulnerability Scanning | - Regular patching and updates<br>- Basic vulnerability scanning | - Rigorous patch management<br>- Regular vulnerability scanning (Amazon Inspector)<br>- Remediation processes and tracking | - Continuous vulnerability scanning<br>- More aggressive patch management processes<br>- Integration with security information and event management (SIEM) tools |
| Backup & Disaster Recovery | - Basic backup (S3, EBS, RDS)<br>- Recovery processes | - More frequent backups<br>- Enhanced recovery processes<br>- Regular testing<br>- Cross-region replication for backups | - High availability and redundancy<br>- Multi-region deployment<br>- Shorter recovery time objectives (RTO) and recovery point objectives (RPO)<br>- Versioning and backup validation |
| Incident Response       | - Basic incident response plan<br>- Notification and escalation processes | - Enhanced incident response plan<br>- Regular testing and updates<br>- Incident response team and training | - Advanced incident response capabilities<br>- Automated response (Lambda, Step Functions)<br>- Continuous improvement based on lessons learned<br>- Integration with external threat intelligence sources |
| Compliance Validation  | - Regular audits and assessments<br>- Compliance with FISMA Low requirements | - More comprehensive audits and assessments<br>- Compliance with FISMA Moderate requirements<br>- AWS Artifact for compliance documentation | - Rigorous audits and assessments<br>- Continuous validation<br>- Compliance with FISMA High requirements<br>- Third-party assessments and certifications |

## FedRAMP Compliance

| Control Area            | FedRAMP Low                                                                 | FedRAMP Moderate                                                                                   | FedRAMP High                                                                                      |
|-------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| Identity & Access Management  | - Basic IAM policies<br>- MFA for privileged users<br>- Regular access reviews. | - More stringent IAM policies<br>- MFA for all users<br>- Role-based access control<br>- Regular access audits<br>- Temporary credentials for short-term access | - Enhanced user monitoring<br>- Continuous access auditing<br>- Additional access restrictions<br>- Session duration limitations<br>- Just-In-Time (JIT) access |
| Data Encryption         | - Encryption at rest (KMS, S3, EBS)<br>- Encryption in transit (TLS)       | - More stringent encryption key management<br>- Automated key rotation<br>- Dedicated KMS Customer Master Keys (CMKs) | - Enhanced encryption algorithms<br>- Hardware security modules (HSM) integration<br>- Stronger key management policies<br>- Key access and usage logging |
| Network Security        | - Basic VPC setup<br>- Security groups<br>- Network ACLs                   | - Enhanced VPC isolation<br>- WAF<br>- Network traffic monitoring<br>- Intrusion detection<br>- VPN or Direct Connect for hybrid environments | - Advanced network protection<br>- Anomaly detection<br>- More comprehensive traffic analysis<br>- Micro-segmentation of network resources<br>- PrivateLink for service access |
| Logging & Monitoring    | - Basic CloudTrail and CloudWatch setup<br>- Log storage and retention     | - Extended logging (S3, Lambda, RDS, etc.)<br>- More granular monitoring<br>- Regular audits<br>- AWS Config for resource tracking | - Real-time continuous monitoring<br>- Advanced analytics (Amazon Elasticsearch, Kinesis)<br>- Automated response capabilities (Lambda, Step Functions)<br>- Centralized logging across accounts and regions |
| Patch Management & Vulnerability Scanning | - Regular patching and updates<br>- Basic vulnerability scanning | - Rigorous patch management<br>- Regular vulnerability scanning (Amazon Inspector)<br>- Remediation processes and tracking | - Continuous vulnerability scanning<br>- More aggressive patch management processes<br>- Integration with security information and event management (SIEM) tools |
| Backup & Disaster Recovery | - Basic backup (S3, EBS, RDS)<br>- Recovery processes | - More frequent backups<br>- Enhanced recovery processes<br>- Regular testing<br>- Cross-region replication for backups | - High availability and redundancy<br>- Multi-region deployment<br>- Shorter recovery time objectives (RTO) and recovery point objectives (RPO)<br>- Versioning and backup validation |
| Incident Response       | - Basic incident response plan<br>- Notification and escalation processes | - Enhanced incident response plan<br>- Regular testing and updates<br>- Incident response team and training | - Advanced incident response capabilities<br>- Automated response (Lambda, Step Functions)<br>- Continuous improvement based on lessons learned<br>- Integration with external threat intelligence sources |
| Compliance Validation  | - Regular audits and assessments<br>- Compliance with FedRAMP Low requirements | - More comprehensive audits and assessments<br>- Compliance with FedRAMP Moderate requirements<br>- AWS Artifact for compliance documentation | - Rigorous audits and assessments<br>- Continuous validation<br>- Compliance with FedRAMP High requirements<br>- Third-party assessments and certifications |


## HIPAA Compliance

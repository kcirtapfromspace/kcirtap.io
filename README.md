# kcirtap.io

## Description

This is my dev blog website available at [kcirtap.io](https://kcirtap.io).
It is built with [Hugo](https://gohugo.io/) and hosted on [AWS](https://aws.amazon.com/).
GitHub Actions are used to build and deploy the website to AWS.
Static content is served from an S3 bucket and the domain is managed by Route53.
CloudFront is used as a CDN and to provide HTTPS.
The website is deployed to a staging environment for pull requests and a production environment for the master branch.
Hopefully, you'll enjoy the content.

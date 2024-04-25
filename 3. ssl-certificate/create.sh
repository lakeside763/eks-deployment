#!/bin/bash
domain_name=$(aws route53 list-hosted-zones --query "HostedZones[0].Name" --output text | xargs | sed 's/.$//')

aws acm request-certificate \
  --domain-name ${domain_name} \
  --subject-alternative-names "*.${domain_name}" \
  --validation-method DNS
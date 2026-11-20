#!/usr/bin/env bash
set -euo pipefail
echo "==> PART 1 — Config, parametres, policies..."

mkdir -p .github/workflows
mkdir -p templates parameters
mkdir -p policies/cfn-guard policies/iam
mkdir -p app/src app/tests
mkdir -p sbom docs/adr scripts
touch sbom/.gitkeep

cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/
.coverage
coverage.xml
htmlcov/
.pytest_cache/
node_modules/
*.pem
*.key
cdk.out/
.aws/
.idea/
.vscode/
*.swp
sbom/*.json
sbom/*.xml
!sbom/.gitkeep
reports/
EOF

cat > .gitleaks.toml << 'EOF'
title = "satom-leman-portail-MF gitleaks config"
[extend]
useDefault = true
[[rules]]
id          = "aws-access-key"
description = "AWS Access Key"
regex       = '''AKIA[0-9A-Z]{16}'''
tags        = ["aws", "credentials"]
[[rules]]
id          = "aws-secret-key"
description = "AWS Secret Key"
regex       = '''(?i)aws_secret_access_key\s*=\s*['\"]?[A-Za-z0-9/+=]{40}['\"]?'''
tags        = ["aws", "credentials"]
[allowlist]
description = "Allowlist"
paths = ['''.gitleaks.toml''', '''docs/adr/.*\.md''']
EOF

cat > sonar-project.properties << 'EOF'
sonar.projectKey=MFelipe06_satom-leman-portail-MF
sonar.organization=mfelipe06
sonar.projectName=satom-leman-portail-MF
sonar.projectVersion=1.0
sonar.sources=app/src
sonar.tests=app/tests
sonar.language=py
sonar.python.coverage.reportPaths=coverage.xml
sonar.qualitygate.wait=true
sonar.coverage.exclusions=app/tests/**
sonar.cpd.exclusions=app/tests/**
EOF

cat > parameters/dev.json << 'EOF'
[
  { "ParameterKey": "Env",        "ParameterValue": "dev"               },
  { "ParameterKey": "VpcCidr",    "ParameterValue": "10.1.0.0/16"       },
  { "ParameterKey": "Suffix",     "ParameterValue": "-MF"               },
  { "ParameterKey": "NatEnabled", "ParameterValue": "false"             },
  { "ParameterKey": "FwEnabled",  "ParameterValue": "false"             },
  { "ParameterKey": "Projet",     "ParameterValue": "SatomCloudNetwork"  },
  { "ParameterKey": "Equipe",     "ParameterValue": "MF"                }
]
EOF

cat > parameters/prod.json << 'EOF'
[
  { "ParameterKey": "Env",        "ParameterValue": "prod"              },
  { "ParameterKey": "VpcCidr",    "ParameterValue": "10.0.0.0/16"       },
  { "ParameterKey": "Suffix",     "ParameterValue": "-MF"               },
  { "ParameterKey": "NatEnabled", "ParameterValue": "true"              },
  { "ParameterKey": "FwEnabled",  "ParameterValue": "true"              },
  { "ParameterKey": "Projet",     "ParameterValue": "SatomCloudNetwork"  },
  { "ParameterKey": "Equipe",     "ParameterValue": "MF"                }
]
EOF

cat > policies/cfn-guard/no-private-subnet-igw.guard << 'EOF'
rule no_private_subnet_igw {
  AWS::EC2::Route {
    when properties.DestinationCidrBlock == "0.0.0.0/0" {
      properties.GatewayId not exists
        or properties.GatewayId not matches /^igw-/
    }
  }
}
EOF

cat > policies/cfn-guard/no-admin-port-public.guard << 'EOF'
rule no_admin_port_public {
  AWS::EC2::SecurityGroup {
    when properties.SecurityGroupIngress exists {
      properties.SecurityGroupIngress[*] {
        when FromPort == 22 or ToPort == 22 {
          CidrIp != "0.0.0.0/0"
          CidrIpv6 != "::/0"
        }
        when FromPort == 3389 or ToPort == 3389 {
          CidrIp != "0.0.0.0/0"
          CidrIpv6 != "::/0"
        }
      }
    }
  }
}
EOF

cat > policies/iam/deploy-role-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudFormationDeploy",
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack", "cloudformation:UpdateStack",
        "cloudformation:DeleteStack", "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents", "cloudformation:GetTemplate",
        "cloudformation:ValidateTemplate", "cloudformation:CreateChangeSet",
        "cloudformation:DescribeChangeSet", "cloudformation:ExecuteChangeSet",
        "cloudformation:DeleteChangeSet", "cloudformation:ListChangeSets"
      ],
      "Resource": "arn:aws:cloudformation:eu-central-2:*:stack/stack-leman-*/*"
    },
    {
      "Sid": "NetworkResources",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:DescribeVpcs",
        "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnets",
        "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
        "ec2:DescribeInternetGateways", "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway", "ec2:DescribeNatGateways",
        "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses",
        "ec2:CreateRouteTable", "ec2:DeleteRouteTable",
        "ec2:CreateRoute", "ec2:DeleteRoute",
        "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
        "ec2:DescribeRouteTables", "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress", "ec2:DescribeSecurityGroups",
        "ec2:CreateNetworkAcl", "ec2:DeleteNetworkAcl",
        "ec2:CreateNetworkAclEntry", "ec2:DeleteNetworkAclEntry",
        "ec2:ReplaceNetworkAclAssociation", "ec2:DescribeNetworkAcls",
        "ec2:CreateVpcPeeringConnection", "ec2:AcceptVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection", "ec2:DescribeVpcPeeringConnections",
        "ec2:CreateVpcEndpoint", "ec2:DeleteVpcEndpoints",
        "ec2:DescribeVpcEndpoints", "ec2:ModifyVpcAttribute",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ComputeResources",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances", "ec2:TerminateInstances",
        "ec2:StartInstances", "ec2:StopInstances",
        "ec2:DescribeInstances", "ec2:DescribeInstanceStatus",
        "ec2:DescribeImages", "ec2:DescribeKeyPairs",
        "ec2:DescribeInstanceTypes", "ec2:ModifyInstanceAttribute",
        "iam:PassRole", "iam:CreateRole", "iam:DeleteRole",
        "iam:AttachRolePolicy", "iam:DetachRolePolicy",
        "iam:PutRolePolicy", "iam:DeleteRolePolicy",
        "iam:GetRole", "iam:GetRolePolicy",
        "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
        "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile",
        "iam:GetInstanceProfile"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SupervisionResources",
      "Effect": "Allow",
      "Action": [
        "config:PutConfigurationRecorder", "config:DeleteConfigurationRecorder",
        "config:DescribeConfigurationRecorders", "config:PutDeliveryChannel",
        "config:DeleteDeliveryChannel", "config:DescribeDeliveryChannels",
        "config:StartConfigurationRecorder",
        "securityhub:EnableSecurityHub", "securityhub:DisableSecurityHub",
        "securityhub:DescribeHub",
        "s3:CreateBucket", "s3:DeleteBucket",
        "s3:PutBucketPolicy", "s3:GetBucketPolicy",
        "s3:PutEncryptionConfiguration", "s3:PutPublicAccessBlock",
        "s3:GetBucketAcl", "s3:PutObject", "s3:GetObject", "s3:ListBucket",
        "network-firewall:CreateFirewall", "network-firewall:DeleteFirewall",
        "network-firewall:DescribeFirewall",
        "network-firewall:CreateFirewallPolicy",
        "network-firewall:DeleteFirewallPolicy",
        "network-firewall:DescribeFirewallPolicy",
        "network-firewall:CreateRuleGroup", "network-firewall:DeleteRuleGroup",
        "network-firewall:DescribeRuleGroup",
        "network-firewall:AssociateFirewallPolicy",
        "network-firewall:TagResource", "network-firewall:ListFirewalls",
        "network-firewall:ListFirewallPolicies",
        "budgets:CreateBudget", "budgets:ModifyBudget",
        "budgets:DeleteBudget", "budgets:DescribeBudgets",
        "sns:CreateTopic", "sns:DeleteTopic",
        "sns:Subscribe", "sns:Unsubscribe",
        "sns:GetTopicAttributes", "sns:SetTopicAttributes"
      ],
      "Resource": "*"
    }
  ]
}
EOF

echo "==> PART 1 terminee."

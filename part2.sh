#!/usr/bin/env bash
set -euo pipefail
echo "==> PART 2 — Templates + App + GitHub Actions..."

# ── templates/network.yaml ───────────────────────────────────
cat > templates/network.yaml << 'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  Reseau — VPC, sous-reseaux, IGW, NAT, tables de routage,
  Network Firewall (conditionnel).
  Sprints 1, 2, 4 — Groupe Leman Finance SA.

Parameters:
  Env:
    Type: String
    AllowedValues: [dev, prod]
  VpcCidr:
    Type: String
    Default: "10.0.0.0/16"
  Suffix:
    Type: String
    Default: "-MF"
  NatEnabled:
    Type: String
    AllowedValues: ["true", "false"]
    Default: "false"
  FwEnabled:
    Type: String
    AllowedValues: ["true", "false"]
    Default: "false"
  Projet:
    Type: String
    Default: SatomCloudNetwork
  Equipe:
    Type: String
    Default: MF

# TODO sprint 1 : VPC, sous-reseaux, IGW
# TODO sprint 2 : NAT, tables de routage
# TODO sprint 4 : Network Firewall

Resources:
  Placeholder:
    Type: AWS::CloudFormation::WaitConditionHandle
EOF

# ── templates/security.yaml ──────────────────────────────────
cat > templates/security.yaml << 'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  Securite — Security Groups, NACL.
  Sprint 3 — Groupe Leman Finance SA.

Parameters:
  Env:
    Type: String
    AllowedValues: [dev, prod]
  Suffix:
    Type: String
    Default: "-MF"
  Projet:
    Type: String
    Default: SatomCloudNetwork
  Equipe:
    Type: String
    Default: MF
  VpcId:
    Type: String

Resources:
  Placeholder:
    Type: AWS::CloudFormation::WaitConditionHandle
EOF

# ── templates/compute.yaml ───────────────────────────────────
cat > templates/compute.yaml << 'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  Calcul — EC2 web-01-MF et app-01-MF, volumes EBS chiffres.
  Sprint 2 — Groupe Leman Finance SA.

Parameters:
  Env:
    Type: String
    AllowedValues: [dev, prod]
  Suffix:
    Type: String
    Default: "-MF"
  Projet:
    Type: String
    Default: SatomCloudNetwork
  Equipe:
    Type: String
    Default: MF

Resources:
  Placeholder:
    Type: AWS::CloudFormation::WaitConditionHandle
EOF

# ── templates/peering.yaml ───────────────────────────────────
cat > templates/peering.yaml << 'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  VPC Peering — prod <-> dev.
  Sprint 5 — Groupe Leman Finance SA.

Parameters:
  Env:
    Type: String
    AllowedValues: [dev, prod]
  Suffix:
    Type: String
    Default: "-MF"
  Projet:
    Type: String
    Default: SatomCloudNetwork
  Equipe:
    Type: String
    Default: MF

Resources:
  Placeholder:
    Type: AWS::CloudFormation::WaitConditionHandle
EOF

# ── templates/edge.yaml ──────────────────────────────────────
cat > templates/edge.yaml << 'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  [PLACEHOLDER] Edge — ALB, Route 53, CloudFront.
  Sprints 9 a 11 — non traites dans cette livraison.

Parameters:
  Env:
    Type: String
  Suffix:
    Type: String
    Default: "-MF"

Resources:
  Placeholder:
    Type: AWS::CloudFormation::WaitConditionHandle
EOF

# ── templates/supervision.yaml ───────────────────────────────
cat > templates/supervision.yaml << 'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  Supervision — Security Hub, AWS Config.
  G0 : Security Hub + Config actives (ADR-008).

Parameters:
  Env:
    Type: String
    AllowedValues: [dev, prod]
  Suffix:
    Type: String
    Default: "-MF"
  Projet:
    Type: String
    Default: SatomCloudNetwork
  Equipe:
    Type: String
    Default: MF

Resources:

  ConfigBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "satom-config-${AWS::AccountId}-${Env}"
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      Tags:
        - Key: Projet
          Value: !Ref Projet
        - Key: Equipe
          Value: !Ref Equipe
        - Key: Environnement
          Value: !Ref Env

  ConfigBucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref ConfigBucket
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: AWSConfigBucketPermissionsCheck
            Effect: Allow
            Principal:
              Service: config.amazonaws.com
            Action: s3:GetBucketAcl
            Resource: !Sub "arn:aws:s3:::${ConfigBucket}"
          - Sid: AWSConfigBucketDelivery
            Effect: Allow
            Principal:
              Service: config.amazonaws.com
            Action: s3:PutObject
            Resource: !Sub "arn:aws:s3:::${ConfigBucket}/AWSLogs/${AWS::AccountId}/Config/*"
            Condition:
              StringEquals:
                s3:x-amz-acl: bucket-owner-full-control

  ConfigRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub "role-config${Suffix}"
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: config.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWS_ConfigRole
      Policies:
        - PolicyName: ConfigS3Access
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action: s3:PutObject
                Resource: !Sub "arn:aws:s3:::${ConfigBucket}/AWSLogs/${AWS::AccountId}/Config/*"
      Tags:
        - Key: Projet
          Value: !Ref Projet
        - Key: Equipe
          Value: !Ref Equipe
        - Key: Environnement
          Value: !Ref Env

  ConfigRecorder:
    Type: AWS::Config::ConfigurationRecorder
    Properties:
      Name: !Sub "config-recorder${Suffix}"
      RoleARN: !GetAtt ConfigRole.Arn
      RecordingGroup:
        AllSupported: true
        IncludeGlobalResourceTypes: true

  ConfigDeliveryChannel:
    Type: AWS::Config::DeliveryChannel
    DependsOn: ConfigBucketPolicy
    Properties:
      S3BucketName: !Ref ConfigBucket
      ConfigSnapshotDeliveryProperties:
        DeliveryFrequency: TwentyFour_Hours

  SecurityHub:
    Type: AWS::SecurityHub::Hub
    DependsOn: ConfigRecorder
    Properties:
      Tags:
        Projet: !Ref Projet
        Equipe: !Ref Equipe
        Environnement: !Ref Env

Outputs:
  ConfigBucketName:
    Value: !Ref ConfigBucket
    Export:
      Name: !Sub "stack-leman-${Env}-ConfigBucket"
  SecurityHubArn:
    Value: !Ref SecurityHub
    Export:
      Name: !Sub "stack-leman-${Env}-SecurityHubArn"
EOF

# ── app/src/server.py ────────────────────────────────────────
cat > app/src/server.py << 'EOF'
"""
Application minimale — Groupe Leman Finance SA
Port 8080 — Sprint 2
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json


class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/health":
            self._respond(200, {"status": "ok", "service": "leman-portail"})
        elif self.path == "/":
            self._respond_html(200, self._index_html())
        else:
            self._respond(404, {"error": "not found"})

    def _respond(self, code, body):
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(payload)

    def _respond_html(self, code, html):
        payload = html.encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(payload)

    def _index_html(self):
        return """<!DOCTYPE html>
<html lang="fr">
<head><meta charset="utf-8"><title>Leman Finance SA</title></head>
<body>
  <h1>Portail Groupe Leman Finance SA</h1>
  <p>Service operationnel.</p>
  <a href="/health">Health check</a>
</body>
</html>"""

    def log_message(self, fmt, *args):
        pass


def run(host="0.0.0.0", port=8080):
    server = HTTPServer((host, port), Handler)
    print(f"Serveur demarre sur {host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
EOF

# ── app/tests/test_server.py ─────────────────────────────────
cat > app/tests/test_server.py << 'EOF'
"""
Tests unitaires — server.py
Couverture cible : >= 80 % (ADR-005)
"""
import io
import sys
import os
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from server import Handler


class MockRequest:
    def makefile(self, *args, **kwargs):
        return io.BytesIO(b"")


class MockServer:
    def __init__(self):
        self.server_address = ("127.0.0.1", 8080)


def make_handler(path):
    raw = f"GET {path} HTTP/1.1\r\nHost: localhost\r\n\r\n".encode()
    output = io.BytesIO()
    handler = Handler.__new__(Handler)
    handler.rfile = io.BytesIO(raw)
    handler.wfile = output
    handler.server = MockServer()
    handler.client_address = ("127.0.0.1", 12345)
    handler.request = MockRequest()
    handler.path = path
    handler.command = "GET"
    handler.request_version = "HTTP/1.1"
    handler.headers = {}
    return handler, output


class TestHealth(unittest.TestCase):
    def test_200(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn("200", o.getvalue().decode())

    def test_json(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn("application/json", o.getvalue().decode())

    def test_status_ok(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn('"status": "ok"', o.getvalue().decode())


class TestIndex(unittest.TestCase):
    def test_200(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("200", o.getvalue().decode())

    def test_html(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("text/html", o.getvalue().decode())

    def test_title(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("Leman Finance SA", o.getvalue().decode())


class TestNotFound(unittest.TestCase):
    def test_404(self):
        h, o = make_handler("/inexistant")
        h.do_GET()
        self.assertIn("404", o.getvalue().decode())


class TestSecurityHeaders(unittest.TestCase):
    def test_xframe(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn("X-Frame-Options", o.getvalue().decode())

    def test_xcontent(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("X-Content-Type-Options", o.getvalue().decode())


if __name__ == "__main__":
    unittest.main()
EOF

# ── app/requirements.txt ─────────────────────────────────────
cat > app/requirements.txt << 'EOF'
# Aucune dependance externe — stdlib Python uniquement
EOF

# ── app/requirements-dev.txt ─────────────────────────────────
cat > app/requirements-dev.txt << 'EOF'
pytest==8.3.4
pytest-cov==6.0.0
EOF

# ── scripts/check-cidr-overlap.py ───────────────────────────
cat > scripts/check-cidr-overlap.py << 'EOF'
#!/usr/bin/env python3
"""Sprint 5 — Verification de non-chevauchement des CIDRs VPC."""
import ipaddress
import sys
import boto3


def get_vpc_cidrs(region):
    ec2 = boto3.client("ec2", region_name=region)
    response = ec2.describe_vpcs(
        Filters=[{"Name": "tag:Projet", "Values": ["SatomCloudNetwork"]}]
    )
    result = []
    for vpc in response["Vpcs"]:
        name = vpc["VpcId"]
        for tag in vpc.get("Tags", []):
            if tag["Key"] == "Name":
                name = tag["Value"]
        result.append({"VpcId": vpc["VpcId"], "CidrBlock": vpc["CidrBlock"], "Name": name})
    return result


def check_overlaps(vpcs):
    errors = []
    networks = [
        (v["Name"], v["VpcId"], ipaddress.ip_network(v["CidrBlock"], strict=False))
        for v in vpcs
    ]
    for i in range(len(networks)):
        for j in range(i + 1, len(networks)):
            na, ia, neta = networks[i]
            nb, ib, netb = networks[j]
            if neta.overlaps(netb):
                errors.append(f"OVERLAP: {na} ({ia}) {neta} chevauche {nb} ({ib}) {netb}")
    return errors


def main():
    region = "eu-central-2"
    print(f"Verification CIDRs dans {region}...")
    vpcs = get_vpc_cidrs(region)
    if not vpcs:
        print("Aucun VPC SatomCloudNetwork trouve.")
        sys.exit(0)
    for v in vpcs:
        print(f"  - {v['Name']} ({v['VpcId']}) : {v['CidrBlock']}")
    errors = check_overlaps(vpcs)
    if errors:
        for e in errors:
            print(e)
        sys.exit(1)
    print("OK — Aucun chevauchement detecte.")
    sys.exit(0)


if __name__ == "__main__":
    main()
EOF

# ── .github/workflows/pipeline.yml ──────────────────────────
cat > .github/workflows/pipeline.yml << 'EOF'
name: pipeline-satom-leman

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  id-token: write
  contents: read
  pull-requests: write

jobs:

  quality:
    name: Qualite statique
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: cfn-lint
        uses: scottbrenner/cfn-lint-action@v2
        with:
          args: "templates/*.yaml"

      - name: cfn-guard
        run: |
          curl -sSL https://raw.githubusercontent.com/aws-cloudformation/cloudformation-guard/main/install-guard.sh | bash
          cfn-guard validate --data templates/network.yaml \
            --rules policies/cfn-guard/no-private-subnet-igw.guard --show-summary all
          cfn-guard validate --data templates/security.yaml \
            --rules policies/cfn-guard/no-admin-port-public.guard --show-summary all

      - name: checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: templates/
          framework: cloudformation
          soft_fail: false

      - name: gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/python

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Tests + couverture
        run: |
          pip install -r app/requirements-dev.txt
          cd app && pytest tests/ --cov=src --cov-report=xml:../coverage.xml --cov-fail-under=80

      - name: SonarCloud
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN:  ${{ secrets.SONAR_TOKEN }}

  security:
    name: Securite statique
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4

      - name: Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          scan-ref: app/
          format: table
          exit-code: 1
          severity: CRITICAL,HIGH

      - name: SBOM Syft
        uses: anchore/sbom-action@v0
        with:
          path: app/
          format: cyclonedx-json
          output-file: sbom/sbom-${{ github.sha }}.json

      - name: Commit SBOM
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "chore: SBOM ${{ github.sha }}"
          file_pattern: sbom/

  deploy-dev:
    name: Deploiement dev
    runs-on: ubuntu-latest
    needs: security
    if: github.ref == 'refs/heads/main'
    environment: dev
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
          aws-region: eu-central-2

      - name: Deploy stack-leman-dev
        run: |
          CS="cs-dev-$(date +%Y%m%d%H%M%S)"
          aws cloudformation create-change-set \
            --stack-name stack-leman-dev \
            --template-body file://templates/network.yaml \
            --parameters file://parameters/dev.json \
            --change-set-name "$CS" \
            --capabilities CAPABILITY_NAMED_IAM \
            --region eu-central-2
          aws cloudformation wait change-set-create-complete \
            --stack-name stack-leman-dev --change-set-name "$CS" --region eu-central-2
          DELETES=$(aws cloudformation describe-change-set \
            --stack-name stack-leman-dev --change-set-name "$CS" --region eu-central-2 \
            --query "Changes[?ResourceChange.Action=='Remove'] | length(@)" --output text)
          if [ "$DELETES" -gt "0" ]; then
            echo "ERREUR : $DELETES suppression(s) — validation manuelle requise."
            aws cloudformation delete-change-set \
              --stack-name stack-leman-dev --change-set-name "$CS" --region eu-central-2
            exit 1
          fi
          aws cloudformation execute-change-set \
            --stack-name stack-leman-dev --change-set-name "$CS" --region eu-central-2
          aws cloudformation wait stack-update-complete \
            --stack-name stack-leman-dev --region eu-central-2

  deploy-prod:
    name: Deploiement prod
    runs-on: ubuntu-latest
    needs: deploy-dev
    if: github.ref == 'refs/heads/main'
    environment: prod
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
          aws-region: eu-central-2

      - name: Deploy stack-leman-prod
        run: |
          CS="cs-prod-$(date +%Y%m%d%H%M%S)"
          aws cloudformation create-change-set \
            --stack-name stack-leman-prod \
            --template-body file://templates/network.yaml \
            --parameters file://parameters/prod.json \
            --change-set-name "$CS" \
            --capabilities CAPABILITY_NAMED_IAM \
            --region eu-central-2
          aws cloudformation wait change-set-create-complete \
            --stack-name stack-leman-prod --change-set-name "$CS" --region eu-central-2
          DELETES=$(aws cloudformation describe-change-set \
            --stack-name stack-leman-prod --change-set-name "$CS" --region eu-central-2 \
            --query "Changes[?ResourceChange.Action=='Remove'] | length(@)" --output text)
          if [ "$DELETES" -gt "0" ]; then
            echo "ERREUR : $DELETES suppression(s) — validation manuelle requise."
            aws cloudformation delete-change-set \
              --stack-name stack-leman-prod --change-set-name "$CS" --region eu-central-2
            exit 1
          fi
          aws cloudformation execute-change-set \
            --stack-name stack-leman-prod --change-set-name "$CS" --region eu-central-2
          aws cloudformation wait stack-update-complete \
            --stack-name stack-leman-prod --region eu-central-2
EOF

# ── .github/workflows/cost-check.yml ────────────────────────
cat > .github/workflows/cost-check.yml << 'EOF'
name: cost-check

on:
  workflow_dispatch:
  schedule:
    - cron: "0 20 * * *"

permissions:
  id-token: write
  contents: read

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
          aws-region: eu-central-2

      - name: NAT Gateways actives
        run: |
          aws ec2 describe-nat-gateways \
            --filter Name=state,Values=available \
            --region eu-central-2 \
            --query "NatGateways[*].{Id:NatGatewayId,Subnet:SubnetId}" \
            --output table

      - name: Network Firewalls actifs
        run: |
          aws network-firewall list-firewalls \
            --region eu-central-2 --output table

      - name: EIP non associees
        run: |
          aws ec2 describe-addresses \
            --region eu-central-2 \
            --query "Addresses[?AssociationId==null].PublicIp" \
            --output table
EOF

# ── .github/pull_request_template.md ────────────────────────
cat > .github/pull_request_template.md << 'EOF'
## Sprint concerne
<!-- ex: Sprint 1 — VPC et sous-reseaux -->

## Description
<!-- Resume des changements -->

## Checklist de revue — auto-revue MF (ADR-006)

### Conformite
- [ ] cfn-lint sans erreur
- [ ] cfn-guard et checkov verts
- [ ] Aucun secret dans le diff (gitleaks vert)
- [ ] Conventional Commit respecte
- [ ] ADR presente si decision significative

### Securite
- [ ] Aucun port 22 ou 3389 ouvert a 0.0.0.0/0
- [ ] Tags presents sur toutes les ressources
- [ ] Volumes EBS chiffres si applicable
- [ ] Aucune cle longue duree dans le code

### Tests
- [ ] Mesure documentee dans docs/couverture.md
- [ ] Entree ajoutee dans docs/journal.md
- [ ] Pipeline verte sur la branche de la PR

### Nettoyage
- [ ] NAT et Firewall desactivables par parametre
- [ ] Aucune ressource orpheline creee manuellement
EOF

echo "==> PART 2 terminee."

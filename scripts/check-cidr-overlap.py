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

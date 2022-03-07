#!/usr/bin/env bash

set -x

DOMAIN="$1"

subfinder -config config.yaml -d "$DOMAIN" -o $DOMAIN-subdomains
altdns -w words-10000.txt -i $DOMAIN-subdomains -o $DOMAIN-altdns-perms -r -s $DOMAIN-subdomains-brute
bin/massdns -r lists/resolvers.txt -t CNAME -w results.txt -o S ../checkout.com-subdomains
subjack -w $DOMAIN-subdomains-brute -t 100 -timeout 30 -o $DOMAIN-results.txt -ssl -c fingerprints.json
subjack -w $DOMAIN-subdomains -t 100 -timeout 30 -o $DOMAIN-results.txt -ssl -c fingerprints.json



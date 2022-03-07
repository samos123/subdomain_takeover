#!/usr/bin/env bash

set -x

DOMAIN="$1"

subfinder -config config.yaml -d "$DOMAIN" -o $DOMAIN-subdomains -all
gotator -sub $DOMAIN-subdomains -perm words-1k.txt -depth 2 -numbers 10 -prefixes -md -silent | shuffledns -r resolvers.txt -d $DOMAIN -o $DOMAIN-subdomains-brute -massdns /usr/local/sbin/massdns -directory .
subjack -w $DOMAIN-subdomains-brute -t 100 -timeout 30 -o $DOMAIN-results.txt -ssl -c fingerprints.json

# old commands
#dnsgen $DOMAIN-subdomains | shuffledns -r resolvers.txt -d $DOMAIN -o $DOMAIN-subdomains-brute -massdns /usr/local/sbin/massdns
#gotator -sub $DOMAIN-subdomains -perm words-1k.txt -depth 2 -numbers 10 -prefixes -md -silent | massdns -r resolvers.txt -t A -w $DOMAIN-subdomains-brute -o J --flush
#dnsgen $DOMAIN-subdomains | massdns -r resolvers.txt -t A -w $DOMAIN-subdomains-brute -o J --flush
#gotator -sub $DOMAIN-subdomains -perm words-1k.txt -depth 2 -numbers 10 -prefixes -md -silent | puredns resolve -w $DOMAIN-subdomains-brute

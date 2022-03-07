#!/bin/sh

set -x

# install golang
GOVERSION=1.17.8
rm -rf /usr/local/go
curl -LO https://go.dev/dl/go$GOVERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$GOVERSION.linux-amd64.tar.gz
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH


# Install dns enumration tools
cd $HOME
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
wget https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt
go get github.com/Josue87/gotator
go get github.com/haccer/subjack
wget https://raw.githubusercontent.com/haccer/subjack/master/fingerprints.json

# Get domain value from GCE metadata
DOMAIN=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/domain" -H "Metadata-Flavor: Google")
echo "Starting subdomain takeover finder for $DOMAIN"
subfinder -config config.yaml -d "$DOMAIN" -o $DOMAIN-subdomains -all
gotator -sub $DOMAIN-subdomains -perm words-1k.txt -depth 2 -numbers 10 -prefixes -md -silent | shuffledns -r resolvers.txt -d $DOMAIN -o $DOMAIN-subdomains-brute -massdns /usr/local/sbin/massdns -directory .
subjack -w $DOMAIN-subdomains-brute -t 100 -timeout 30 -o $DOMAIN-results.txt -ssl -c fingerprints.json
gsutil cp $DOMAIN-results.txt gs://samos123-pentest/

# Delete the VM itself
export NAME=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/name -H 'Metadata-Flavor: Google')
export ZONE=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/zone -H 'Metadata-Flavor: Google')
#gcloud --quiet compute instances delete $NAME --zone=$ZONE

#!/bin/bash

set -x

export GOROOT=/usr/local/go
export GOPATH=/root/go
export GOCACHE=/root/go/cache
export HOME=/root
cd /root
mkdir -p /root/go
export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

# install golang
if [ ! -f "finished-install" ]; then
GOVERSION=1.17.8
rm -rf /usr/local/go
curl -LO https://go.dev/dl/go$GOVERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go$GOVERSION.linux-amd64.tar.gz

# Install dns enumration tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
wget https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
go install github.com/Josue87/gotator@latest
go install github.com/haccer/subjack@latest
wget https://raw.githubusercontent.com/haccer/subjack/master/fingerprints.json
apt-get update
apt-get install -y gcc make
git clone https://github.com/blechschmidt/massdns
pushd massdns
make
cp bin/massdns /usr/local/sbin/
popd

gsutil cp gs://samos123-pentest/config.yaml .
gsutil cp gs://samos123-pentest/words-1k.txt .

# install ops agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
touch finished-install
fi

# Get domain value from GCE metadata
DOMAIN=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/domain" -H "Metadata-Flavor: Google")
if [ ! -f "gotator-done" ]; then
  echo "Starting subdomain takeover finder for $DOMAIN"
  subfinder -pc config.yaml -d "$DOMAIN" -o $DOMAIN-subdomains -all
  mkdir enum
  gotator -sub $DOMAIN-subdomains -perm words-1k.txt -depth 2 -numbers 5 -prefixes -md -silent -adv | \
      split --suffix-length 5 --filter 'gzip > $FILE.gz' -d -b 5G - enum/$DOMAIN-subdomains-enum
  touch gotator-done
fi
for filename in enum/*; do
  gzip -d -c $filename | \
    shuffledns -silent -r resolvers.txt -d $DOMAIN \
        -o $filename-resolved -massdns /usr/local/sbin/massdns -directory .
  subjack -w $filename-resolved -t 100 -timeout 30 -o $filename-subjack -ssl -c fingerprints.json -a
  if test -f "$filename-subjack"; then
    cat $filename-subjack
    gsutil cp $filename-subjack gs://samos123-pentest/
  fi
#  rm $filename
done

cat enum/*resolved* | uniq > $DOMAIN-resolved
gsutil cp $DOMAIN-resolved gs://samos123-pentest/

# Delete the VM itself
export NAME=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/name -H 'Metadata-Flavor: Google')
export ZONE=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/zone -H 'Metadata-Flavor: Google')
gcloud --quiet compute instances delete $NAME --zone=$ZONE

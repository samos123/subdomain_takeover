#!/usr/bin/env bash

DOMAIN=$1

ID=$(tr -dc a-z0-9 </dev/urandom | head -c 2 ; echo '')

gcloud beta compute instances create brute-dns-$ID \
  --boot-disk-size=300GB \
  --boot-disk-type=pd-balanced \
  --project=samos123-pentest \
  --zone=us-central1-f \
  --provisioning-model=SPOT \
  --instance-termination-action=STOP \
  --image-project=ubuntu-os-cloud \
  --image-family=ubuntu-2004-lts \
  --metadata=domain=$DOMAIN \
  --metadata-from-file=startup-script=startup.sh \
  --scopes=default,storage-rw,compute-rw \
  --machine-type=t2d-standard-2

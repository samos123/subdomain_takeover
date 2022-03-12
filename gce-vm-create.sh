#!/usr/bin/env bash

DOMAIN=$1

gcloud beta compute instances create brute-dns \
  --boot-disk-size=100GB \
  --boot-disk-type=pd-balanced \
  --project=samos123-pentest \
  --zone=us-central1-f \
  --provisioning-model=SPOT \
  --instance-termination-action=DELETE \
  --image-project=ubuntu-os-cloud \
  --image-family=ubuntu-2004-lts \
  --metadata=domain=$DOMAIN \
  --metadata-from-file=startup-script=startup.sh \
  --machine-type=t2d-standard-2

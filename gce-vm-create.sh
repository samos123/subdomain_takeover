#!/usr/bin/env bash

DOMAIN=$1

gcloud beta compute instances create brute-dns \
  --project=samos123-pentest \
  --provisioning-model=SPOT \
  --instanceinstance-termination-action=DELETE \
  --image-project=ubuntu-cloud \
  --image-family=ubuntu-2004-lts \
  --metadata=domain=$DOMAIN \
  --metadata-from-file=startup-script=startup.sh \
  --machine-type=t2d-standard-1

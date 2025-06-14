#!/bin/bash

docker-compose down

for i in 1 2; do
  for j in 1 2 3; do
    rm -rfv vault${i}${j}/data/* vault${i}${j}/audit/* vault${i}${j}/snapshots/*
    # ls -lR vault${i}${j}
  done
done

rm -rfv certs/terraform.tfstate* certs/wildcard

rm -rfv openldap/*

rm -rfv traefik/log/*

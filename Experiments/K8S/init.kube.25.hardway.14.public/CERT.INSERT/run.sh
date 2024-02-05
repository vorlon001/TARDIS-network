#!/bin/bash

cp ./*.crt  /usr/local/share/ca-certificates/
update-ca-certificates


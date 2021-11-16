#!/bin/bash

dir="$(dirname "$0")"

openssl genrsa -out "$dir/private.key" 4096
openssl rsa -in "$dir/private.key" -pubout > "$dir/data/daemon/validation-key.pub"

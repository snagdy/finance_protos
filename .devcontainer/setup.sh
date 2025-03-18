#!/bin/bash
make setup 
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc 
. ~/.bashrc 
[ -d ~/.ssh ] && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa* && 
ssh-keyscan -H github.com >> ~/.ssh/known_hosts || echo "Skipping SSH configuration; no keys found."
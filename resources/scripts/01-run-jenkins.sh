#!/bin/bash

print_line_break(){
  echo ' '
}

print_separator() {
  echo "------------------------------------------------"
}

print_log() {
  local str="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') -> $str"
}

print_separator
print_log "Starting Jenkins installation (Docker)..."
print_line_break

# Create Jenkins volume data directory
sudo mkdir /jenkins_home
sudo chmod 777 /jenkins_home

# Navigate to docker deploy dir
cd /docker-deploys/jenkins
# Build custom image and launch jenkins
docker compose up -d --build

print_line_break
print_log "Finished Jenkins installation."
print_separator

#! /bin/bash

# A script to pull the datastore out of the container

if vagrant status default | grep -q 'running'; then
  echo "Found running container to $1 datastore"
else
  echo "Vagrant container not running, skipping..."
  exit 0
fi

local_dir=dev-datastore
mkdir -p $local_dir
config=$(vagrant ssh-config)

host=$(echo -e "${config}" | grep HostName | cut -d " " -f 4)
port=$(echo -e "${config}" | grep Port | cut -d " " -f 4)
keyfile=$(echo -e "${config}" | grep IdentityFile | cut -d " " -f 4)

if [ $1 == 'pull' ]; then
  src="root@$host:/datastore/*"
  dst="./$local_dir"
else
  dst="root@$host:/datastore"
  src="./$local_dir/*"
fi

# We want this to fail if the ssh command fails
echo "Updating ssh known hosts..."
ssh-keygen -R $host
scp -r -P $port -i $keyfile -oStrictHostKeyChecking=no $src $dst
#!/usr/bin/env sh

echo "** ethiab ** Initializing geth"

geth init \
  --datadir "/root/data/execution/2" \
  /root/execution/genesis.json

echo "** ethiab ** Installing curl, jq, and GNU sed"
apk update
apk add curl jq sed

echo "** ethiab ** Getting enode from ec1"
enode=$(curl --data '{"method":"admin_nodeInfo","id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST 172.16.8.2:8545 -s | jq -r '.result.enode')
echo "** ethiab ** enode: $enode"

ec1Ip="172.16.8.2"
enode="\"${enode/127.0.0.1/$ec1Ip}\""
echo "** ethiab ** enode ip replaced: $enode"

echo "** ethiab ** Setting enode in ec2.toml"
# We use pipe delimeter due to the forward slashes in enode
sed -i '/BootstrapNodes/,/BootstrapNodesV5/s|\[.*\]|['"${enode}"']|' /root/execution/ec2.toml

echo "** ethiab ** Starting geth"

geth \
  --config /root/execution/ec2.toml "$@"

#!/bin/bash

leader=$(ssh HOSTNAME consul operator raft list-peers |grep leader)

leader=$(echo $leader | cut -d' ' -f1)

echo "Actual leader is $leader. Coup in Progress..."

ssh $leader sudo systemctl restart consul

new_leader=$(ssh HOSTNAME consul operator raft list-peers |grep leader|cut -d' ' -f1)

echo "The king is dead, long live the king: $new_leader!"

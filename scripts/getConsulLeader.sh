#!/bin/bash

leader=$(ssh HOSTNAME consul operator raft list-peers |grep leader)

echo $leader


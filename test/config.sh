#!/bin/bash
set -e

testAlias+=(
	[signatumd:xenial]='signatumd'
)

imageTests+=(
	[signatumd]='
		rpcpassword
	'
)

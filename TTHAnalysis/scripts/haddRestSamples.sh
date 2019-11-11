#!/bin/bash
set -e

## hadd chunks
$CMSSW_BASE/src/urlToBashLink.sh make ./ ## generate links from the urls
haddChunks.py -n -c .

exit 0

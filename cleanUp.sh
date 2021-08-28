#!/bin/bash

# File to fix import paths for the generated D modules
protoCodeFile=source/libdnet/protobuf/dnet.d

# Fix up
cat $protoCodeFile | sed -e "s/source.libdnet.protobuf./ /" > tmpFile

# This thing got whacky
mv tmpFile $protoCodeFile

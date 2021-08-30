#!/bin/bash

# File to fix import paths for the generated D modules
protoCodeFile=source/libdnet/protobuf/dnet.d

# Fix up
cat $protoCodeFile | sed -e "s/import source.libdnet.protobuf./public import /" > tmpFile

# Fix up module header
cat tmpFile | sed -e "s/dnet/libdnet.protobuf.dnet/" > tmpFile2
rm tmpFile

# This thing got whacky
mv tmpFile2 $protoCodeFile

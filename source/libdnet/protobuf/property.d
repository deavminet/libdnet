// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: source/libdnet/protobuf/property.proto

module property;

import google.protobuf;

enum protocVersion = 3014000;

class Property
{
    @Proto(1) string name = protoDefaultValue!string;
    @Proto(2) bytes data = protoDefaultValue!bytes;
}
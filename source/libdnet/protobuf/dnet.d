// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: source/libdnet/protobuf/dnet.proto

module libdnet.protobuf.dnet;

import google.protobuf;

enum protocVersion = 3014000;

class DNETMessage
{
    @Proto(1) MessageType type = protoDefaultValue!MessageType;
    @Proto(2) bytes content = protoDefaultValue!bytes;

    enum MessageType
    {
        ACCOUNT = 0,
        CHANNEL = 1,
        SERVER = 2,
    }
}

class AccountMessage
{
    @Proto(1) MessageType type = protoDefaultValue!MessageType;
    @Proto(2) string name = protoDefaultValue!string;
    @Proto(3) bytes additionalData = protoDefaultValue!bytes;

    enum MessageType
    {
        AUTH = 0,
        REGISTRATION = 1,
        DEREG = 2,
        GET_PROFILE_PROPS = 3,
        SET_PROFILE_PROP = 4,
        GET_PROFILE_PROP = 5,
        LOGOUT = 6,
    }
}

class ChannelMessage
{
    @Proto(1) MessageType type = protoDefaultValue!MessageType;
    @Proto(2) string name = protoDefaultValue!string;
    @Proto(3) bytes additionalData = protoDefaultValue!bytes;

    enum MessageType
    {
        CREATE = 0,
        DESTROY = 1,
        JOIN = 2,
        LEAVE = 3,
        SET_PROP = 4,
        GET_PROPS = 5,
        GET_MEMBERS = 6,
        GET_PROP = 7,
        NEW_MESSAGE_ALERT = 8,
    }
}

class Property
{
    @Proto(1) string name = protoDefaultValue!string;
    @Proto(2) bytes data = protoDefaultValue!bytes;
}

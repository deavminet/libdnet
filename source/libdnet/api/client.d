module libdnet.api.client;

import libdnet.protobuf.dnet;

/**
* Client
*
* Represents a connection to the server. This
* contains quite a number of things such as
* basic command support, notifications support
* (asynchronous) allowing one to attached handlers
* to each different asynchronous message types.
*
* Along with the basic command support is the ability
* to queue tasks up and have handlers attached to them
* for when they complete (server-side asycnrhonous support
* is mirrored into the library)
*/
public final class Client
{
    public Channel createChannel(string name)
    {
        Channel newChannel;

        /* TODO: Check if the channel exists firstly */
        ChannelMessage d = new ChannelMessage();
        d.name = name;
        d.type = ChannelMessage.MessageType.CREATE;

        return newChannel;
    }
}

public final class Channel
{

}
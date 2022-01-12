/**
* Type declarations
*/
module libdnet.messages.types;

import msgpack;

/* TODO: Add structs here */


public enum HeaderType
{
	CLIENT,
	SERVER
}

/**
* Header format
*
* [ messageType | payload ]
*/
struct Header
{
	/**
	* Type of message
	*
	* How the `payload` should be
	* interpreted
	*/
	HeaderType type;

	/**
	* Data of the message
	*/
	ubyte[] payload;
}


/**
* Server message
*
* TODO: Describe message
*/
struct ServerMessage
{
	/* TODO: Populate */
}


/**
* ClientType
*
* The type of ClientMessage
*/
public enum ClientType
{
	AUTH,
	ENTITYMESSAGE,
	FETCH_PROFILE
}

/**
* Client message
*
* TODO: Describe message
*/
struct ClientMessage
{
	/* TODO: Populate */
	ClientType type;

	ubyte[] payload;
}

/**
* AuthenticateMessage
*
* This message is used to authenticate
* the user with the server
*/
struct AuthenticateMessage
{
	string username;
	string password;
}

/**
* EntityMessage
*
* A message to a user or a channel
*/
struct EntityMessage
{
	/**
	* Sender-receiver details
	*/
	string to;
	string from;

	/* Payload */
	string message;

	/* Timestamp (date and time) */
	string timestamp;
}

/**
* ProfileMessage
*
* A user's profile
*/
struct ProfileMessage
{
	string fullname;
	string server;
	string hostmask;

	/*
	* Keys for extra data
	*/
	string[] dataKeys;
}

struct KeyedData
{
	string key;
	ubyte[] data;
}


/**
* Testing header creation, encoding and
* decoding
*/
unittest
{
	/* Create a new Header */
	Header testHeader;
	testHeader.type = HeaderType.CLIENT;
	testHeader.payload = [1,2,3,4];

	/* Encode Header */
	ubyte[] encodedHeader= pack(testHeader);

	/* Decode the Header */
	Header headerReceived = unpack!(Header)(encodedHeader);

	/* Make sure it was properly received */
	assert(headerReceived.type == testHeader.type);
	assert(headerReceived.payload[0] == testHeader.payload[0]);
	assert(headerReceived.payload[1] == testHeader.payload[1]);
	assert(headerReceived.payload[2] == testHeader.payload[2]);
	assert(headerReceived.payload[3] == testHeader.payload[3]);
}

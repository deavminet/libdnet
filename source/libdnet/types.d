/**
* Type declarations
*/
module libdnet.types;

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
	AUTH
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

struct AuthenticateMessage
{
	string username;
	string password;
}

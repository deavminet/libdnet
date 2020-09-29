module libdnet.dclient;

import tristanable.manager : Manager;
import std.socket;
import std.stdio;
import std.conv : to;
import std.string : split;

public final class DClient
{
	/**
	* tristanabale tag manager
	*/
	private Manager manager;


	/* TODO: Tristsnable doesn't, unlike my java version, let youn really reuse tags */
	/* TODO: Reason is after use they do not get deleted, only later by garbage collector */
	/* TODO: To prevent weird stuff from possibly going down, we use unique ones each time */
	private long i = 20;

	/**
	* Constructs a new DClient and connects
	* it to the given endpoint Address
	*
	* @param address the endpoint (server) to
	* connect to
	*/
	this(Address address)
	{
		/* Initialize the socket */
		Socket socket = new Socket(address.addressFamily, SocketType.STREAM, ProtocolType.TCP);
		socket.connect(address);
		
		/* Initialize the manager */
		manager = new Manager(socket);
	}

	/**
	* Authenticates as a client with the server
	*
	* @param username the username to use
	* @param password the password to use
	* @returns bool true on successful authentication,
	* false otherwise
	*/
	public bool auth(string username, string password)
	{
		/* The protocol data to send */
		byte[] data = [0];
		data ~= cast(byte)username.length;
		data ~= username;
		data ~= password;

		/* Send the protocol data */
		manager.sendMessage(i, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* Set next available tag */
		i++;

		return cast(bool)resp[0];
	}


	/**
	* Joins the given channel
	*
	* @param channel the channel to join
	* @returns bool true if the join was
	* successful, false otherwise
	*/
	public bool join(string channel)
	{
		/* TODO: DO oneshot as protocol supports csv channels */

		/* The protocol data to send */
		byte[] data = [3];
		data ~= channel;

		/* Send the protocol data */
		manager.sendMessage(i, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* Set next available tag */
		i++;

		return cast(bool)resp[0];
	}

	/**
	* Lists all the channels on the server
	*
	* @returns string[] the list of channels
	*/
	public string[] list()
	{
		/* List of channels */
		string[] channels;

		/* The protocol data to send */
		byte[] data = [6];

		/* Send the protocol data */
		manager.sendMessage(i, data);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* Only generate a list if command was successful */
		if(resp[0])
		{
			/* Generate the channel list */
			string channelList = cast(string)resp[1..resp.length];
			channels = split(channelList, ",");
		}

		/* Set next available tag */
		i++;

		return channels;
	}

	public Manager getManager()
	{
		return manager;
	}

	/**
	* Sends a message to either a channel of user
	*
	* @param isUser whether or not we are sending to
	* a user, true if user, false if channel
	* @param location the username/channel to send to
	* @param message the message to send
	* @returns bool whether the send worked or not
	*/
	public bool sendMessage(bool isUser, string location, string message)
	{
		/* The protocol data to send */
		byte[] protocolData = [5];

		/**
		* If we are sending to a user then the
		* type field is 0, however if to a channel
		* then it is one
		*
		* Here we encode that
		*/
		protocolData ~= [!isUser];

		/* Encode the length of `location` */
		protocolData ~= [cast(byte)location.length];

		/* Encode the user/channel name */
		protocolData ~= cast(byte[])location;

		/* Encode the message */
		protocolData ~= cast(byte[])message;

		/* Send the protocol data */
		manager.sendMessage(i, protocolData);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* Set next available tag */
		i++;

		return cast(bool)resp[0];
	}

	/**
	* Returns the list of members in the
	* given channel
	*/
	public string[] getMembers(string channel)
	{
		/* The list of members */
		string[] members;

		/* The protocol data to send */
		byte[] protocolData = [9];

		/**
		* Encode the channel name
		*/
		protocolData ~= cast(byte[])channel;

		/* Send the protocol data */
		manager.sendMessage(i, protocolData);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* If the operation completed successfully */
		if(resp[0])
		{
			string memberList = cast(string)resp[1..resp.length];
			members = split(memberList, ",");
		}
		/* If there was an error */
		else
		{
			/* TODO: Error handling */
		}

		/* Set next available tag */
		i++;

		return members;
	}

	/**
	* Returns the count of members in the
	* given channel
	*/
	public ulong getMemberCount(string channelName)
	{
		/* The member count */
		long memberCount;
	
		/* The protocol data to send */
		byte[] protocolData = [8];

		/* Encode the channel name */
		protocolData ~= cast(byte[])channelName;

		/* Send the protocol data */
		manager.sendMessage(i, protocolData);

		/* Receive the server's response */
		byte[] resp = manager.receiveMessage(i);

		/* Check if the operation completed successfully */
		if(resp[0])
		{
			/* Length as byte array */
			byte[] numberBytes;
			numberBytes.length = 8;

			/* As Skippy would say, this is jank, but I literay am so lazy now hehe */
			memberCount = *cast(long*)resp[1..resp.length].ptr;

			/* Decode the length (Big Endian) to Little Endian */
			numberBytes[0] = *((cast(byte*)&memberCount)+7);
			numberBytes[1] = *((cast(byte*)&memberCount)+6);
			numberBytes[2] = *((cast(byte*)&memberCount)+5);
			numberBytes[3] = *((cast(byte*)&memberCount)+4);
			numberBytes[4] = *((cast(byte*)&memberCount)+3);
			numberBytes[5] = *((cast(byte*)&memberCount)+2);
			numberBytes[6] = *((cast(byte*)&memberCount)+1);
			numberBytes[7] = *((cast(byte*)&memberCount)+0);

			memberCount = *cast(long*)numberBytes.ptr;
			
		}
		else
		{
			/* TODO: Error handling */
		}

		/* Set next available tag */
		i++;

		return memberCount;
	}

	/**
	* Disconnect from the server
	*
	* TODO: This is still a work in progress
	* due to tristanable's disconnect still
	* being a work in progress
	*/
	public void close()
	{
		/* FIXME: I must fix manager for this, the socket stays active and hangs the .join */
		/* FIXME (above): due to it being blocking, although I did think I closed the socket */
		/* TODO: Not the above, it's actually garbage collector */
		manager.stopManager();	
		writeln("manager stopped");
	}
}
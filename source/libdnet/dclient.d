module libdnet.dclient;

import tristanable.manager : Manager;
import tristanable.queue : Queue;
import tristanable.encoding : DataMessage;
import tristanable.queueitem : QueueItem;
import std.socket;
import std.stdio;
import std.conv : to;
import std.string : split;
import bmessage : bSendMessage = sendMessage;

public final class DClient
{
	/**
	* tristanabale tag manager
	*/
	private Manager manager;
	private Socket socket;
	/* Create a queue for normal traffic (request-reply on tag: 0) */
	private	Queue reqRepQueue;

		/* Create a queue for notifications (replies-only on tag: 1) */
	private Queue notificationQueue;


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
		/* TODO: Error handling */
		socket = new Socket(address.addressFamily, SocketType.STREAM, ProtocolType.TCP);
		socket.connect(address);
		
		/* Initialize tristanable */
		initTristanable(socket);
	}

	private void initTristanable(Socket socket)
	{
		/* Initialize the manager */
		manager = new Manager(socket);

		/* Create a queue for normal traffic (request-reply on tag: 1) */
		reqRepQueue = new Queue(1);

		/* Create a queue for notifications (replies-only on tag: 0) */
		notificationQueue = new Queue(0);

		/* Add these queues to the tracker */
		manager.addQueue(reqRepQueue);
		manager.addQueue(notificationQueue);
	}

	/**
	* Receives the head of the notification queue
	*/
	public byte[] awaitNotification()
	{
		/* The received notification */
		byte[] notification;

		/* Await the notification */
		QueueItem queueItem = notificationQueue.dequeue();

		/* Grab the notification's data */
		notification = queueItem.getData();

		return notification;
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
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

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
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		return cast(bool)resp[0];
	}

	/**
	* Set your status
	*
	*
	*/
	public void setStatus(string status)
	{
		/* The protocol data to send */
		byte[] data = [13];
		data ~= status;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		// return cast(bool)resp[0];
	}

	/**
	* Get the memberinfo of a given user
	*
	* TODO: Return more thna just status
	*/
	public string getMemberInfo(string user)
	{
		/* The protocol data to send */
		byte[] data = [12];
		data ~= user;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();


		string status;

		/* If it worked */
		if(cast(bool)resp[0])
		{
			/* The member info */
			ubyte len1 = resp[1];
			ubyte len2 = resp[1+len1+1];
			status = cast(string)resp[1+len1+1+len2+1..resp.length];
		}
		else
		{
			/* TODO: Handle error */
		}

		return status;
	}


	/**
	* Lists all properties of the given user
	*/
	public string[] getProperties(string user)
	{
		/* The protocol data to send */
		byte[] data = [15];
		data ~= user;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* Received list of properties */
		string[] properties;

		/* If it worked */
		if(cast(bool)resp[0])
		{
			/* Get the property line */
			string propertyLine = cast(string)resp[1..resp.length];

			properties = split(propertyLine, ",");
		}

		return properties;
	}

	/**
	* Get a property's value
	*/
	public string getProperty(string user, string property)
	{
		/* The property's value */
		string propertyValue;

		/* The protocol data to send */
		byte[] data = [16];
		data ~= user~","~property;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* If it worked */
		if(cast(bool)resp[0])
		{
			/* Get the property line */
			propertyValue = cast(string)resp[1..resp.length];
		}

		return propertyValue;
	}

	/**
	* Check's whether the user has the given property
	*/
	public bool isProperty(string user, string property)
	{
		/* The property's value */
		bool status;

		/* The protocol data to send */
		byte[] data = [19];
		data ~= user~","~property;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* If it worked */
		if(cast(bool)resp[0])
		{
			/* Get the property line */
			status = cast(bool)resp[1];
		}

		return status;
	}

	/**
	* Set's the given property of yourself to the given value
	*/
	public void setProperty(string property, string propertyValue)
	{
		/* The property's value */
		bool status;

		/* The protocol data to send */
		byte[] data = [17];
		data ~= property~","~propertyValue;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* If it worked */
		if(cast(bool)resp[0])
		{
			
		}
	}

	/**
	* Delete's the given property of yourself
	*/
	public void deleteProperty(string property)
	{
		/* The property's value */
		bool status;

		/* The protocol data to send */
		byte[] data = [18];
		data ~= property;

		/* Send the protocol data */
		DataMessage protocolData = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolData.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* If it worked */
		if(cast(bool)resp[0])
		{
			
		}
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
		DataMessage protocolDataMsg = new DataMessage(reqRepQueue.getTag(), data);
		bSendMessage(socket, protocolDataMsg.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* Only generate a list if command was successful */
		if(resp[0])
		{
			/* Generate the channel list */
			string channelList = cast(string)resp[1..resp.length];
			channels = split(channelList, ",");
		}

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
		DataMessage protocolDataMsg = new DataMessage(reqRepQueue.getTag(), protocolData);
		bSendMessage(socket, protocolDataMsg.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

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
		DataMessage protocolDataMsg = new DataMessage(reqRepQueue.getTag(), protocolData);
		bSendMessage(socket, protocolDataMsg.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

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
		DataMessage protocolDataMsg = new DataMessage(reqRepQueue.getTag(), protocolData);
		bSendMessage(socket, protocolDataMsg.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

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

	public string getMotd()
	{
		/* The message of the day */
		string motd;

		/* The protocol data to send */
		byte[] protocolData = [11];

		/* Send the protocol data */
		DataMessage protocolDataMsg = new DataMessage(reqRepQueue.getTag(), protocolData);
		bSendMessage(socket, protocolDataMsg.encode());

		/* Receive the server's response */
		byte[] resp = reqRepQueue.dequeue().getData();

		/* Check if the operation completed successfully */
		if(resp[0])
		{
			/* Set the message of the day */
			motd = cast(string)resp[1..resp.length];
		}
		else
		{
			/* TODO: Error handling */
		}

		/* Set next available tag */
		i++;

		return motd;
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
		//manager.stopManager();	
		writeln("manager stopped");
	}
}
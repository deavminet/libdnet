/**
* TODO: We should make this a basew class that people have to ovverride and provide implementations for
* that hook into specific job descriptors
*/
module libdnet.libdnet;

import std.socket : Address, Socket;
import tasky.engine : Engine, TaskyEvent;
import tasky.jobs : Descriptor;


import libdnet.messages.types;

import msgpack;

/* TODO: Remove this when we use the newer version of tasky (which uses TaskyEvent) */
import eventy.event : Event;

import dlog;

public class Client
{
	/**
	* Without __gshared, this would cause us to have a `logger` per-thread
	* and statically init a new DefaultLogger() for each respective `logger` field
	*
	* This makes sure we have one `logger` field for ALL threads and therefore
	* only one static initialization.
	*
	* Funnily enough if you wanted the opposite behaviour, omitting the `__gshared`
	* will not help, DMD complains. One must make it explicit I guess with a 
	* static initialization block `static this()`.
	*/
	private __gshared static Logger logger = new DefaultLogger();

	private Engine engine;


	private Address endpoint;



	private Socket sock;



	/**
	* TODO: We need to re-write Tasky before we can start work on this (urgent)
	* TODO: We need to add signal handling to tristanable (not, urgent)
	* TODO: We need to check eventy and make sure it is fully completed and
	* documented and working (also check if it requires any signal handling, doubt)
	*/
	this(Address endpoint)
	{
		/* TODO: Initialize stuff here */

		this.endpoint = endpoint;

		/* Open socket here */
		this.sock = new Socket();
		

		/* Initialize a new Tasky engine */
		engine = new Engine(sock);

		/* Register handlers */
		registerHandlers();
	}


	public enum SpecProtocolID : byte
	{
		NEWMESSAGE
	}

	/**
	* Protocols
	*/
	private ulong[SpecProtocolID] ids;


	/**
	* Registers all of the handlers
	*/
	private final void registerHandlers()
	{
		/* Register the message handler */
		Descriptor messageHandlerDesc = new class Descriptor
		{
				this()
				{
					super(0);
				}
		
				public override void handler_TaskyEvent(TaskyEvent e)
				{
					/* Call the entry point handler */
					messageHandler_entry(e);
				}
		};
		ids[SpecProtocolID.NEWMESSAGE] = messageHandlerDesc.getDescriptorClass();

		/* TODO: Handler IDs must match the specifition so these should be set in sequence */



		/**
		* TODO: Only output when in debug mode
		*/
		logger.log("<<< Protocol specification breakdown >>>");
		import std.conv : to;
		foreach(SpecProtocolID specID; ids.keys())
		{
			logger.log("["~to!(string)(specID)~"] = "~to!(string)(ids[specID]));
		}
	}

	unittest
	{
		logger.log("unittesting with null address family (no connect() call)");
		Client c = new Client(null);
		
	}


	/**
	* New message handler
	*
	* This is called whenever a new message arrives
	*
	* TODO: Switch to `TaskyEvent e`
	*/
	private final void messageHandler_entry(TaskyEvent e)
	{
		/* Get the payload */
		ubyte[] eventPayload = cast(ubyte[])e.getPayload();

		/* TODO: Check for msgpack errors */

		/* Unpack the message */
		EntityMessage message = unpack!(EntityMessage)(eventPayload);

		/* Call the handler */
		messageHandler(message);
		
		
	}

	/**
	* Override this to provide your handler for new messages
	*/
	public void messageHandler(EntityMessage message)
	{
		import std.stdio;
		writeln(message);
	}


	/**
	* Authenicate with the server
	*
	* This is a handler that will get a unique descriptor
	* for this given authentication attempt such that it
	* matches up the reply, you want to ovveride authResponseHandler
	*/
	public void auth(string[] credentials)
	{
		/* TODO: Do auth */

		/* TODO: Set the handler to `authResponseHandler` */
		Descriptor desc;

		/* TODO: Check if descriptor IDs available */
		
		/* Get the descriptor ID */
		desc.getDescriptorClass();
	}

	public void authResponseHandler()
	{
		
	}


	/**
	* Connect to the server
	*/
	public final void start()
	{
		/* TODO: Catch errors: Connect the socket to the endpoint host */
		sock.connect(endpoint);
		
		/* Start the Tasky engine */
		engine.start();
	}

}

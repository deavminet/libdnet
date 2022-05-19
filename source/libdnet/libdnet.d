/**
* TODO: We should make this a basew class that people have to ovverride and provide implementations for
* that hook into specific job descriptors
*/
module libdnet.libdnet;

import std.socket : Address;
import tasky.engine : Engine;

public class Client
{
	private Engine engine;


	private Address endpoint;







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
	}


	/**
	* Connect to the server
	*/
	public void connect()
	{
		/* FIXME: Don't start Tasky engine till we are actually connected (FIX in Tasky) */

		/* Initialize a new Tasky engine */
		//engine = new Engine();

		/* Start the Tasky engine */
		//engine.start();
	}


	/**
	* Login
	*/
	public void login(string[] credentials)
	{

	}

	/**
	* Shutsdown the client
	*/
	public void shutdown()
	{
		/* TODO: Logout if not already logged out */

		/* TODO: Get tasky to shutdown */
	}


	/* TODO: Hook ~this() onto shutdown() */

	/**
	* When the next cycle of the garbage collector
	* runs and realises there is a zero-refcount
	* to this object then shutdown the client
	*/
	~this()
	{
		/* Shutdown the client */
		shutdown();
	}
}

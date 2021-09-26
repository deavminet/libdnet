module libdnet.api.client;

import libdnet.protobuf.dnet;
import std.socket;
import tristanable.manager;
import tristanable.queue;
import tasky;
import libdnet.api.exceptions;


/**
* ConnectionDetails
*
* Contains user credentials and network
* information used when connecting to
* a DNET server
*/
public struct ConnectionDetails
{
    import std.conv : to;
    
    public string username;
    public string password;
    public Address address;

    this(string[] credentials, string[] address)
    {
        /* Credentials must be valid */
        if(credentials.length != 2)
        {
            throw new DNetException("Credentials must be tuple of length 2");
        }

        /* Address must be valid */
        if(address.length != 2)
        {
            throw new DNetException("Address must be tuple of length 2");
        }
        
        
        /* FIXME: Also throw for invalid address */

        this.username = credentials[0];
        this.password = credentials[1];
        this.address = parseAddress(address[0], to!(ushort)(address[1]));
    }
}

public final class Client
{
    /**
    * Server connection details
    */
    private ConnectionDetails connInfo;

    /**
    * Protocol task manager (I/O)
    */
    private TaskManager taskManager;

    this(ConnectionDetails connInfo)
    {
        /* Set the connection details */
        this.connInfo = connInfo;
    }

    /**
    * Attempts to connect to the server indicated by the
    * ConnectionDetails provided on construction
    */
    public void connect()
    {
        /* Attempt to create a connection */
        /* FIXME: Add SocketOSException catch */
        Socket serverSock = new Socket(connInfo.address.addressFamily, SocketType.STREAM, ProtocolType.TCP);

        /* Initialize a new Tasky engine */
        taskManager = new TaskManager(serverSock);
    }
}
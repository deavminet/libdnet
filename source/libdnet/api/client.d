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
        
        /**
        * Credentials must be valid
        *
        * 1. Must not both be empty
        * 2. We must also strip the username of any whitespace on any side (FIXME)
        */
        if(!(credentials[0].length > 0 && credentials[1].length > 0))
        {
            throw new DNetException("Username or password has incorrect length");
        }

        /* Save credentials */
        this.username = credentials[0];
        this.password = credentials[1];

        /**
        * Addresses must be valid
        *
        * 1. Must not be empty
        */
        if(address[0].length > 0 && address[1].length > 0)
        {
            /* Make sure they pass address syntax check */
            try
            {
                /* Save address */
                this.address = parseAddress(address[0], to!(ushort)(address[1]));
            }
            catch(SocketException)
            {
                throw new DNetException("Invalid address format (error in port or address)");
            }
        }
        else
        {
            throw new DNetException("Address or port has incorrect length");
        }
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
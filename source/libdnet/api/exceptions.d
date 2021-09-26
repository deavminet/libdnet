module libdnet.api.exceptions;

import libdnet.api.client : Client;


public class DNetException : Exception
{
    private Client client;

    this(string message)
    {
        super(message);
        // this.client = client;
    }


}

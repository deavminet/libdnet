module libdnet.exceptions;

public class DClientException : Exception
{
    /* TODO: Constructor */
    this(string errorMessage)
    {
        super("[DClientException] "~errorMessage);
    }
}

public class DNetworkError : DClientException
{
    this(string command)
    {
        super("NetworkError: "~command);
    }
}
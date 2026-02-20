using System.Net;

namespace FinBalancer.Api.Exceptions;

/// <summary>API iznimka s HTTP status kodom – za namjerno vraćanje grešaka klijentu.</summary>
public class ApiException : Exception
{
    public HttpStatusCode StatusCode { get; }
    public string? ErrorCode { get; }

    public ApiException(HttpStatusCode statusCode, string message, string? errorCode = null)
        : base(message)
    {
        StatusCode = statusCode;
        ErrorCode = errorCode;
    }

    public ApiException(int statusCode, string message, string? errorCode = null)
        : this((HttpStatusCode)statusCode, message, errorCode) { }
}

using System.Net;
using FinBalancer.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace FinBalancer.Api.Filters;

/// <summary>Pretvara standardne HTTP error rezultate u konzistentan ApiErrorResponse format.</summary>
public class ApiErrorResultFilter : IAlwaysRunResultFilter
{
    public void OnResultExecuting(ResultExecutingContext context)
    {
        if (context.Result is ObjectResult objectResult && objectResult.Value is ApiErrorResponse)
            return;

        var (statusCode, error, message, errorCode) = context.Result switch
        {
            UnauthorizedResult => (401, "Unauthorized", "Authentication required.", "Unauthorized"),
            UnauthorizedObjectResult uo when uo.Value is not ApiErrorResponse => (401, "Unauthorized", GetMessage(uo.Value), GetErrorCode(uo.Value) ?? "Unauthorized"),
            NotFoundResult => (404, "Not Found", "Resource not found.", "NotFound"),
            NotFoundObjectResult no when no.Value is not ApiErrorResponse => (404, "Not Found", GetMessage(no.Value), GetErrorCode(no.Value) ?? "NotFound"),
            BadRequestResult => (400, "Bad Request", "Invalid request.", "BadRequest"),
            BadRequestObjectResult bo when bo.Value is not ApiErrorResponse => (400, "Bad Request", GetMessage(bo.Value), GetErrorCode(bo.Value) ?? "BadRequest"),
            ConflictResult => (409, "Conflict", "Resource conflict.", "Conflict"),
            ObjectResult co when co.StatusCode is 400 or 409 && co.Value is not ApiErrorResponse => ((int)(co.StatusCode ?? 400), "Error", GetMessage(co.Value), GetErrorCode(co.Value) ?? "Error"),
            _ => (0, "", "", (string?)null)
        };

        if (statusCode == 0) return;

        var response = new ApiErrorResponse(Error: error, Message: message, ErrorCode: errorCode ?? error, TraceId: context.HttpContext.TraceIdentifier);
        context.Result = new ObjectResult(response) { StatusCode = statusCode };
    }

    public void OnResultExecuted(ResultExecutedContext context) { }

    private static string GetMessage(object? value)
    {
        if (value == null) return "An error occurred.";
        if (value is string s) return s;
        if (value is ProblemDetails pd && !string.IsNullOrEmpty(pd.Detail)) return pd.Detail;
        if (value is ProblemDetails pd2 && !string.IsNullOrEmpty(pd2.Title)) return pd2.Title;
        if (value is { } obj)
        {
            var msg = obj.GetType().GetProperty("Message")?.GetValue(obj) as string;
            if (!string.IsNullOrEmpty(msg)) return msg;
            var err = obj.GetType().GetProperty("Error")?.GetValue(obj) as string;
            if (!string.IsNullOrEmpty(err)) return err;
        }
        return value.ToString() ?? "An error occurred.";
    }

    private static string? GetErrorCode(object? value)
    {
        if (value == null) return null;
        return value.GetType().GetProperty("ErrorCode")?.GetValue(value) as string;
    }
}

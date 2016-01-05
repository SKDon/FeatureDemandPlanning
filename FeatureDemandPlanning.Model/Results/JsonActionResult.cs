using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Results
{
    public class JsonActionResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public bool IsValidation { get; set; }
        public IEnumerable<string> ValidationErrors { get; set; }

        public JsonActionResult(string message = "")
        {
            Success = true;
            Message = message;
        }
        public static JsonActionResult GetSuccess(string message = "")
        {
            return new JsonActionResult(message);
        }
        public static JsonActionResult GetFailure(string message = "")
        {
            return new JsonActionResult(message)
            {
                Success = false
            };
        }
        public static JsonActionResult GetFailure(Exception exception)
        {
            var result = new JsonActionResult()
            {
                Success = false,
                Message = exception.Message
            };
            if (exception is ValidationException)
            {
                var errors = ((ValidationException)exception).Errors.Select(e => e.ErrorMessage);
                result.IsValidation = true;
                result.ValidationErrors = errors;
            }
            return result;
        }
    }
}
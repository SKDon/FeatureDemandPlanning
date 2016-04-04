using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DocumentFormat.OpenXml.Wordprocessing;

namespace FeatureDemandPlanning.Model.Results
{
    public class JsonActionResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public object Data { get; set; }
        public bool IsValidation { get; set; }
        public IEnumerable<string> ValidationErrors { get; set; }

        public JsonActionResult(string message = "")
        {
            Success = true;
            Message = message;
            Data = null;
        }
        public static JsonActionResult GetSuccess(string message = "")
        {
            return new JsonActionResult(message);
        }
        public static JsonActionResult GetSuccess(object data, string message = "")
        {
            return new JsonActionResult(message)
            {
                Data = data
            };
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
            if (!(exception is ValidationException)) return result;
            
            var errors = new List<string>();
            foreach (var err in ((ValidationException) exception).Errors)
            {
                if (err.CustomState != null && err.CustomState.ToString().StartsWith("LINE:"))
                {
                    var lineNumber = int.Parse(err.CustomState.ToString().Replace("LINE:", string.Empty));
                    errors.Add(string.Format("{0} (line {1})", err.ErrorMessage, lineNumber));
                }
                else
                {
                    errors.Add(err.ErrorMessage);
                }
            }
                
            result.IsValidation = true;
            result.ValidationErrors = errors;

            var sb = new StringBuilder();
            sb.Append("Validation Failed:<br/><br/>");
            sb.Append("<ul>");
            foreach (var err in result.ValidationErrors)
            {
                sb.Append("<li>");
                sb.Append(err);
                sb.Append("</li>");
            }
            sb.Append("</ul>");

            result.Message = sb.ToString();

            return result;
        }
    }
}
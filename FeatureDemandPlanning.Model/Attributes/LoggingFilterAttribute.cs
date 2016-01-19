using System.Diagnostics;
using System.Reflection;
using System.Text;
using System.Web.Mvc;
using log4net;

namespace FeatureDemandPlanning.Model.Attributes
{
    public class LoggingFilterAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (!Log.IsDebugEnabled)
                return;

            var loggingWatch = Stopwatch.StartNew();
            filterContext.HttpContext.Items.Add(StopWatchKey, loggingWatch);

            var message = new StringBuilder();
            message.Append(string.Format("Executing controller {0}, action {1}",
                filterContext.ActionDescriptor.ControllerDescriptor.ControllerName,
                filterContext.ActionDescriptor.ActionName));

            Log.Debug(message);
        }
        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            if (!Log.IsDebugEnabled || filterContext.HttpContext.Items[StopWatchKey] == null)
                return;

            var loggingWatch = (Stopwatch) filterContext.HttpContext.Items[StopWatchKey];
            loggingWatch.Stop();

            var timeSpent = loggingWatch.ElapsedMilliseconds;

            var message = new StringBuilder();
            message.Append(string.Format("Finished executing controller {0}, action {1} - time spent {2}",
                filterContext.ActionDescriptor.ControllerDescriptor.ControllerName,
                filterContext.ActionDescriptor.ActionName,
                timeSpent));

            Log.Debug(message);
            filterContext.HttpContext.Items.Remove(StopWatchKey);
        }

        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
        private const string StopWatchKey = "DebugLoggingStopwatch";
    }
}
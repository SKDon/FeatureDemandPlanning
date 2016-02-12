using System.Diagnostics;
using System.Text;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.Model.Attributes
{
    public class LoggingFilterAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var loggingWatch = Stopwatch.StartNew();
            filterContext.HttpContext.Items.Add(StopWatchKey, loggingWatch);

            var message = new StringBuilder();
            message.Append(string.Format("Controller {0} :: {1}",
                filterContext.ActionDescriptor.ControllerDescriptor.ControllerName,
                filterContext.ActionDescriptor.ActionName));

            Log.Debug(message.ToString());
        }
        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            if (filterContext.HttpContext.Items[StopWatchKey] == null)
                return;

            var loggingWatch = (Stopwatch)filterContext.HttpContext.Items[StopWatchKey];
            loggingWatch.Stop();

            var timeSpent = loggingWatch.ElapsedMilliseconds;

            var message = new StringBuilder();
            message.Append(string.Format("Controller {0} :: {1} :: {2} ms",
                filterContext.ActionDescriptor.ControllerDescriptor.ControllerName,
                filterContext.ActionDescriptor.ActionName,
                timeSpent));

            Log.Debug(loggingWatch.ElapsedMilliseconds);
            filterContext.HttpContext.Items.Remove(StopWatchKey);
        }

        private static readonly Logger Log = Logger.Instance;
        private const string StopWatchKey = "DebugLoggingStopwatch";
    }
}
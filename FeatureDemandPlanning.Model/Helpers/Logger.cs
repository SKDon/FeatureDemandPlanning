using System;
using System.Runtime.CompilerServices;
using System.Web;
using log4net;

namespace FeatureDemandPlanning.Model.Helpers
{
    public class Logger
    {
        public static Logger Instance
        {
            get { return _logger ?? (_logger = new Logger()); }
        }
        public void Error(Exception ex,
            [CallerMemberName] string memberName = "",
            [CallerFilePath] string sourceFilePath = "",
            [CallerLineNumber] int sourceLineNumber = 0)
        {
            if (_log == null)
            {
                Initialise();
            }
            _log.Error(string.Format("Error Logged from Method {0} in file {1} at line {2} :: {3}",
                memberName, sourceFilePath, sourceLineNumber, GetAuthenticatedUser()), ex);
        }
        public void Warning(Exception ex,
            [CallerMemberName] string memberName = "",
            [CallerFilePath] string sourceFilePath = "",
            [CallerLineNumber] int sourceLineNumber = 0)
        {
            if (_log == null)
            {
                Initialise();
            }
            _log.Error(string.Format("Warning from Method {0} in file {1} at line {2} :: {3}",
                memberName, sourceFilePath, sourceLineNumber, GetAuthenticatedUser()), ex);
        }
        public void Debug(object debugInfo,
            [CallerMemberName] string memberName = "",
            [CallerFilePath] string sourceFilePath = "",
            [CallerLineNumber] int sourceLineNumber = 0)
        {
            if (_log == null)
            {
                Initialise();
            }
            _log.Debug(string.Format("Debug Info from Method {0} in file {1} at line {2} :: {3} :: {4}",
                memberName, sourceFilePath, sourceLineNumber, debugInfo, GetAuthenticatedUser()));
        }
        public void Debug(
            object debugInfo,
            Exception ex,
            [CallerMemberName] string memberName = "",
            [CallerFilePath] string sourceFilePath = "",
            [CallerLineNumber] int sourceLineNumber = 0)
        {
            if (_log == null)
            {
                Initialise();
            }
            _log.Debug(string.Format("Debug Info from Method {0} in file {1} at line {2} :: {3} :: {4}",
                memberName, sourceFilePath, sourceLineNumber, debugInfo, GetAuthenticatedUser()), ex);
        }
        public void Info(
            object info,
            [CallerMemberName] string memberName = "",
            [CallerFilePath] string sourceFilePath = "",
            [CallerLineNumber] int sourceLineNumber = 0)
        {
            if (_log == null)
            {
                Initialise();
            }
            _log.Info(string.Format("Info from Method {0} in file {1} at line {2} :: {3} :: {4}",
                memberName, sourceFilePath, sourceLineNumber, info, GetAuthenticatedUser()));
        }
        public void Info(
            object info,
            Exception ex,
            [CallerMemberName] string memberName = "",
            [CallerFilePath] string sourceFilePath = "",
            [CallerLineNumber] int sourceLineNumber = 0)
        {
            if (_log == null)
            {
                Initialise();
            }
            _log.Info(string.Format("Info from Method {0} in file {1} at line {2} :: {3} :: {4}",
                memberName, sourceFilePath, sourceLineNumber, info, GetAuthenticatedUser()), ex);
        }
        public bool IsDebugEnabled
        {
            get { return _log.IsDebugEnabled; }
        }
        private Logger()
        {
        }
        private void Initialise()
        {
            _log = LogManager.GetLogger(typeof (Logger));
            log4net.Config.XmlConfigurator.Configure();
        }
        private static string GetAuthenticatedUser()
        {
            return HttpContext.Current == null ? string.Empty : ParseUserName(HttpContext.Current.User.Identity.Name);
        }

        private static string ParseUserName(string userName)
        {
            var retVal = userName;
            if (!string.IsNullOrEmpty(userName) && userName.Contains(@"\"))
            {
                retVal = userName.Substring(userName.LastIndexOf(@"\", StringComparison.OrdinalIgnoreCase) + 1);
            }
            return retVal;
        }
        private static Logger _logger;
        private ILog _log;
    }
}

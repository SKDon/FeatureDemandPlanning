using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Web;
using System.Web.Caching;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.Model
{
    [DataContract]
    public class SharedModelBase
    {
        public ConfigurationSettings Configuration { get; set; }
        public string CurrentPage { get; set; }
        public User CurrentUser { get; set; }

        public string CurrentVersion { get; set; }
        public string HTMLTitle { get; set; }

        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int TotalRecords { get; set; }
        public int TotalDisplayRecords { get; set; }
        public int TotalPages { get; set; }
        public string CookieKey { get; set; }

        public string IdentifierPrefix { get; set; }

        public string StatusCode
        {
            get
            {
                if (!ProcessStates.Any())
                    return string.Empty;

                return ProcessStates.First().Status.ToString();
            }
        }

        public string StatusMessage
        {
            get
            {
                if (!ProcessStates.Any())
                    return string.Empty;

                var messages = ProcessStates.First().Messages;

                return !messages.Any() ? string.Empty : messages.First();
            }
        }
        public IEnumerable<ProcessState> ProcessStates { get { return _processStates; } }

        public void AddProcessState(ProcessState state)
        {
            _processStates.Add(state);
        }

        public void SetProcessState(ProcessState state)
        {
            _processStates = new List<ProcessState>() { state };
        }

        public void SetProcessState(ApplicationException ex)
        {
            _processStates = new List<ProcessState>() { new ProcessState(ex) };
        }
        public SharedModelBase()
        {

        }
        public SharedModelBase(SharedModelBase baseModel)
        {
            CurrentUser = baseModel.CurrentUser;
            CurrentVersion = baseModel.CurrentVersion;
        }
        public static SharedModelBase GetBaseModel(IDataContext context)
        {
            return new SharedModelBase()
            {
                CurrentUser = GetUser(context),
                CurrentVersion =  Assembly.GetExecutingAssembly().GetName().Version.ToString()
            };
        }
        private static User GetUser(IDataContext context)
        {
            User retVal;
            var cdsId = GetAuthenticatedUser();
            var cachedUser = HttpContext.Current.Cache.Get(cdsId);
            if (cachedUser != null)
            {
                retVal = (User)cachedUser;
            }
            else
            {
                retVal = context.User.GetUser();
                HttpContext.Current.Cache.Insert(cdsId, retVal, null, DateTime.Now.AddMinutes(30), Cache.NoSlidingExpiration);
            }
            return retVal;
        }
        private static string GetAuthenticatedUser()
        {
            try
            {
                return ParseUserName(HttpContext.Current.User.Identity.Name);
            }
            catch (Exception)
            {
                //Logger.Instance.Error(ex);
                return string.Empty;
            }
        }
        private static string ParseUserName(string userName)
        {
            var retVal = userName;
            if (userName.Contains(@"\"))
            {
                retVal = userName.Substring(userName.LastIndexOf(@"\", StringComparison.OrdinalIgnoreCase) + 1);
            }
            return retVal;
        }

        private IList<ProcessState> _processStates = new List<ProcessState>();
        protected static readonly Logger Log = Logger.Instance;
    }
}

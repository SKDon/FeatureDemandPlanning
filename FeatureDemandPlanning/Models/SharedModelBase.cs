using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Models
{
    [DataContract]
    public abstract class SharedModelBase
    {
        public SharedModelBase(IDataContext dataContext)
        {
            _dataContext = dataContext;
        }

        public string CurrentPage { get; set; }
        
        [IgnoreDataMember]
        public SystemUser CurrentUser { get { return _dataContext.User.GetUser(); } }
        public IDataContext DataContext { get { return _dataContext; } }
        public string CurrentVersion { get { return Assembly.GetExecutingAssembly().GetName().Version.ToString(); } }
        public string HTMLTitle { get; set; }

        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int TotalRecords { get; set; }
        public int TotalPages { get; set; }
        public int ViewPage { get; set; }

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

                if (!messages.Any())
                    return string.Empty;

                return messages.First();
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

        private IDataContext _dataContext = null;
        private IList<ProcessState> _processStates = new List<ProcessState>();
    }
}

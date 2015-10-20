using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Caching;
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
        public static string CurrentVersion { get { return Assembly.GetExecutingAssembly().GetName().Version.ToString(); } }
        public string HTMLTitle { get; set; }

        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int TotalRecords { get; set; }
        public int TotalDisplayRecords { get; set; }
        public int TotalPages { get; set; }
        public string CookieKey { get; set; }

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

        protected IVehicle InitialiseVehicle(IVehicle vehicle)
        {
            var cacheKey = string.Format("Vehicle_{0}", vehicle.GetHashCode());
            IVehicle returnValue = (IVehicle)HttpContext.Current.Cache.Get(cacheKey);
            if (returnValue != null)
            {
                returnValue.TrimMappings = vehicle.TrimMappings;
                return returnValue;
            }

            returnValue = this.DataContext.Vehicle.GetVehicle(VehicleFilter.FromVehicle(vehicle));
            returnValue.TrimMappings = vehicle.TrimMappings;

            HttpContext.Current.Cache.Add(
                cacheKey, 
                returnValue, 
                null,
                DateTime.Now.AddMinutes(60), 
                Cache.NoSlidingExpiration, 
                CacheItemPriority.Default, null);

            return returnValue;
        }

        private IDataContext _dataContext = null;
        private IList<ProcessState> _processStates = new List<ProcessState>();
    }
}

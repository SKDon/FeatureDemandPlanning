using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;

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

        //protected IVehicle InitialiseVehicle(IVehicle vehicle)
        //{
        //    var cacheKey = string.Format("Vehicle_{0}", vehicle.GetHashCode());
        //    IVehicle returnValue = (IVehicle)HttpContext.Current.Cache.Get(cacheKey);
        //    if (returnValue != null)
        //    {
        //        returnValue.TrimMappings = vehicle.TrimMappings;
        //        return returnValue;
        //    }

        //    returnValue = this.DataContext.Vehicle.GetVehicle(VehicleFilter.FromVehicle(vehicle));
        //    returnValue.TrimMappings = vehicle.TrimMappings;

        //    HttpContext.Current.Cache.Add(
        //        cacheKey, 
        //        returnValue, 
        //        null,
        //        DateTime.Now.AddMinutes(60), 
        //        Cache.NoSlidingExpiration, 
        //        CacheItemPriority.Default, null);

        //    return returnValue;
        //}

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
                CurrentUser = context.User.GetUser(),
                CurrentVersion =  Assembly.GetExecutingAssembly().GetName().Version.ToString()
            };
        }

        private IList<ProcessState> _processStates = new List<ProcessState>();
    }
}

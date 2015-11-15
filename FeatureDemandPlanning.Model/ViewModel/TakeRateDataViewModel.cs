using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class TakeRateDataViewModel : SharedModelBase
    {
        #region "Constants"

        private const string CountryKey = "Country of Assembly";

        #endregion

        public IEnumerable<ReferenceList> Countries { get; set; }
        public TakeRateDataAction CurrentAction { get; set; }
        public TakeRateData Data { get; set; }
        public OXODoc Document { get; set; }
        public Market Market { get; set; }
        public MarketGroup MarketGroup { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public Programme Programme { get; set; }

        #region "Constructors"

        public TakeRateDataViewModel()
        {
            InitialiseMembers();
        }
        public TakeRateDataViewModel(SharedModelBase modelBase)
            : base(modelBase)
        {
            InitialiseMembers();
        }

        #endregion

        #region "Public Methods"

        public static async Task<TakeRateDataViewModel> GetModel(IDataContext context,
                                                           TakeRateDataFilter filter,
                                                           TakeRateDataAction action)
        {
            var model = await GetModel(context, filter);
            model.CurrentAction = action;
            if (action != TakeRateDataAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(action.GetType(), action);
            }

            return model;
        }
        public static async Task<TakeRateDataViewModel> GetModel(IDataContext context, TakeRateDataFilter filter)
        {
            TakeRateDataViewModel model;
            switch (filter.Action)
            {
                case TakeRateDataAction.Summary:
                    model = await GetFullAndPartialViewModelForSummary(context, filter);
                    break;
                case TakeRateDataAction.Data:
                    model = await GetFullAndPartialViewModelForData(context, filter);
                    break;
                default:
                    model = await GetFullAndPartialViewModel(context, filter);
                    break;
            }
            return model;
        }
        private static async Task<TakeRateDataViewModel> GetFullAndPartialViewModel(IDataContext context, TakeRateDataFilter filter)
        {
            var model = new TakeRateDataViewModel()
            {
                Document = GetOxoDocument(context, OXODoc.FromTakeRateDataFilter(filter)),
                Mode = filter.Mode
            };
            model.Data = await ListTakeRateData(context, model);
            
            return model;
        }
        private static Task<TakeRateDataViewModel> GetFullAndPartialViewModelForData(IDataContext context, TakeRateDataFilter filter)
        {
            throw new NotImplementedException();
        }

        private static Task<TakeRateDataViewModel> GetFullAndPartialViewModelForSummary(IDataContext context, TakeRateDataFilter filter)
        {
            throw new NotImplementedException();
        }

        #endregion

        #region "Private Methods"

        private void InitialiseMembers()
        {
            Document = new EmptyOxoDocument();
            CurrentAction = TakeRateDataAction.NotSet;
            Mode = TakeRateResultMode.PercentageTakeRate;
            Programme = new EmptyProgramme();
            Market = new EmptyMarket();
            MarketGroup = new MarketGroup();
        }
        private static OXODoc GetOxoDocument(IDataContext context, OXODoc forOxoDocument)
        {
            OXODoc oxoDocument;
            var cacheKey = string.Format("OxoDocument_{0}", forOxoDocument.Id);
            var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
            if (cachedLookup != null)
            {
                oxoDocument = (OXODoc)cachedLookup;
            }
            else
            {
                oxoDocument = context.TakeRate.GetOxoDocument(new VolumeFilter() { OxoDocId = forOxoDocument.Id, ProgrammeId = forOxoDocument.ProgrammeId });
                HttpContext.Current.Cache.Add(cacheKey, oxoDocument, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return oxoDocument;
        }
        
       
        //private static TakeRateSummary GetVolumeHeader(IDataContext context, TakeRateSummary forHeader)
        //{
        //    TakeRateSummary header;
        //    var cacheKey = string.Format("FdpVolumeHeader_{0}", forHeader.TakeRateId);
        //    var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
        //    if (cachedLookup != null)
        //    {
        //        header = (TakeRateSummary)cachedLookup;
        //    }
        //    else
        //    {
        //        header = context.TakeRate.GetVolumeHeader(new VolumeFilter() { FdpVolumeHeaderId = forHeader.TakeRateId });
        //        HttpContext.Current.Cache.Add(cacheKey, header, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
        //    }

        //    // Get the vehicle associated with the import data
        //    //header.Vehicle = (Vehicle)context.Vehicle.GetVehicle(new VehicleFilter()
        //    //{
        //    //    ProgrammeId = header.ProgrammeId,
        //    //    Gateway = header.Gateway
        //    //});

        //    return header;
        //}
        //private static async Task<PagedResults<TakeRateSummary>> ListVolumeSummary(IDataContext context, Volume forVolume)
        //{
        //    if (forVolume.Document is EmptyOxoDocument)
        //        return new PagedResults<TakeRateSummary>();

        //    return await context.TakeRate.ListTakeRateData(TakeRateDataFilter.FromVolume(forVolume));
        //}
        private static async Task<TakeRateData> ListTakeRateData(IDataContext context, TakeRateDataViewModel takeRateDataView)
        {
            if (takeRateDataView.Document is EmptyOxoDocument)
                return await Task.FromResult(new TakeRateData());

            return await context.TakeRate.ListVolumeData(TakeRateDataFilter.FromTakeRateDataViewModel(takeRateDataView));
        }
        

        #endregion

        #region "Private Members"

        private IVolume _volume = new EmptyVolume();

        #endregion
    }
}
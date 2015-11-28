using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Context;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class FdpOxoVolumeViewModel : SharedModelBase
    {
        #region "Constants"

        private const string countryKey = "Country of Assembly";

        #endregion

        #region "Constructors"

        public FdpOxoVolumeViewModel() : base()
        {
            InitialiseMembers();
        }
        public FdpOxoVolumeViewModel(SharedModelBase modelBase) : base(modelBase)
        {
            InitialiseMembers();
        }

        #endregion

        #region "Public Properties"

        public IEnumerable<ReferenceList> Countries { get; set; }
        public LookupViewModel VehicleLookup { get; set; }
        public Volume Volume
        {
            get { return (Volume)_volume; }
            set { _volume = value; InitialiseVolume(); }
        }

        #endregion

        #region "Public Methods"

        public static Task<FdpOxoVolumeViewModel> GetFullAndPartialViewModel(IDataContext context)
        {
            return GetFullAndPartialViewModel(context, 
                                                new VolumeFilter(), 
                                                new PageFilter());
        }
        public static Task<FdpOxoVolumeViewModel> GetFullAndPartialViewModel(IDataContext context, VolumeFilter filter, PageFilter pageFilter)
        {
            var volume = context.Volume.GetVolume(filter);
            return GetFullAndPartialViewModel(context, volume, pageFilter);
        }
        public static async Task<FdpOxoVolumeViewModel> GetFullAndPartialViewModel(IDataContext context, IVolume forVolume, PageFilter pageFilter)
        {
            var modelBase = GetBaseModel(context);
            var volumeModel = new FdpOxoVolumeViewModel(modelBase) 
            { 
                Volume = (Volume)forVolume, 
                PageSize = pageFilter.PageSize,
                Configuration = context.ConfigurationSettings,
                Countries = context.References.ListReferencesByKey(countryKey)
            };
               
            HydrateOxoDocument(context, volumeModel);
            HydrateFdpVolumeHeaders(context, volumeModel);
            await HydrateFdpVolumeHeadersFromOxoDocument(context, volumeModel);
            HydrateVehicle(context, volumeModel);
            HydrateLookups(context, forVolume, volumeModel);
            HydrateMarkets(context, volumeModel);
            HydrateData(context, volumeModel);

            if (!(volumeModel.Volume.Document is EmptyOxoDocument))
            {
                volumeModel.PageIndex = (int)FeatureDemandPlanning.Model.Enumerations.VolumePage.VolumeData;
            }
            else
            {
                volumeModel.PageIndex = pageFilter.PageIndex;
            }

            return volumeModel;
        }

        #endregion

        #region "Private Methods"

        private void InitialiseMembers()
        {
            Volume = new EmptyVolume();
        }
        private void InitialiseVolume()
        {
            InitialiseVehicle();
        }
        private void InitialiseVehicle()
        {
            if (Volume.Vehicle is EmptyVehicle)
            {
                return;
            }

            //Volume.Vehicle = (Vehicle)InitialiseVehicle(Volume.Vehicle);
        }
        private static void HydrateLookups(IDataContext context, IVolume volume, FdpOxoVolumeViewModel volumeModel)
        {
            volumeModel.VehicleLookup = GetLookup(context, volume.Vehicle);
        }
        private static void HydrateMarkets(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            HydrateMarket(context, volumeModel);
            HydrateMarketGroup(context, volumeModel);
            HydrateDerivativesByMarket(context, volumeModel);
        }
        private static void HydrateMarket(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            if (volumeModel.Volume.Market is EmptyMarket)
                return;

            volumeModel.Volume.Market = GetMarket(context, volumeModel.Volume.Market, volumeModel.Volume.Document);
        }
        private static void HydrateMarketGroup(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            if (volumeModel.Volume.MarketGroup is EmptyMarketGroup)
                return;

            volumeModel.Volume.MarketGroup = GetMarketGroup(context, volumeModel.Volume.MarketGroup, volumeModel.Volume.Document);
        }
        private static void HydrateDerivativesByMarket(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            volumeModel.Volume.Vehicle.AvailableModels = ListAvailableModelsFilteredByMarket(context, volumeModel.Volume);
        }
        private static void HydrateFdpVolumeHeaders(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            var volumeSummary = new List<TakeRateSummary>();
            foreach (var header in volumeModel.Volume.VolumeSummary)
            {
                var newHeader = GetVolumeHeader(context, header);
                //volumeSummary.Add(newHeader);
                //volumeModel.Volume.Vehicle.AvailableImports = newHeader.Vehicle.AvailableImports;
                //volumeModel.Volume.Vehicle.AvailableDocuments = newHeader.Vehicle.AvailableDocuments;
            }

            volumeModel.Volume.VolumeSummary = volumeSummary;
        }
        private async static Task HydrateFdpVolumeHeadersFromOxoDocument(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            if (volumeModel.Volume.VolumeSummary.Any())
                return;

            var volumeHeaders = await ListVolumeSummary(context, volumeModel.Volume);
            volumeModel.Volume.VolumeSummary = volumeHeaders.CurrentPage;
        }
        private static void HydrateOxoDocument(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            volumeModel.Volume.Document = GetOxoDocument(context, volumeModel.Volume.Document);

            volumeModel.Volume.Vehicle.ProgrammeId = volumeModel.Volume.Document.ProgrammeId;
            volumeModel.Volume.Vehicle.Gateway = volumeModel.Volume.Document.Gateway;
        }
        private static void HydrateData(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            volumeModel.Volume.VolumeData = ListVolumeData(context, volumeModel.Volume);
        }
        private static void HydrateVehicle(IDataContext context, FdpOxoVolumeViewModel volumeModel)
        {
            if (!(volumeModel.Volume.Vehicle is EmptyVehicle))
                return;

            volumeModel.Volume.Vehicle = GetVehicle(context, volumeModel.Volume.Vehicle, volumeModel.Volume.Document);
            // Set this prior to filtering by market
            volumeModel.Volume.TotalDerivatives = volumeModel.Volume.Vehicle.AvailableModels.Count();
        }
        private static LookupViewModel GetLookup(IDataContext context, IVehicle forVehicle)
        {
            LookupViewModel lookup = null;
            var cacheKey = string.Format("ProgrammeLookup_{0}", forVehicle.GetHashCode());
            var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
            if (cachedLookup != null)
            {
                lookup = (LookupViewModel)cachedLookup;
            }
            else
            {
                lookup = LookupViewModel.GetModelForVehicle(forVehicle, context);
                HttpContext.Current.Cache.Add(cacheKey, lookup, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return lookup;
        }
        private static OXODoc GetOxoDocument(IDataContext context, OXODoc forOxoDocument)
        {
            OXODoc oxoDocument = new EmptyOxoDocument();
            var cacheKey = string.Format("OxoDocument_{0}", forOxoDocument.Id);
            var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
            if (cachedLookup != null)
            {
                oxoDocument = (OXODoc)cachedLookup;
            }
            else
            {
                oxoDocument = context.Volume.GetOxoDocument(new VolumeFilter() { OxoDocId = forOxoDocument.Id, ProgrammeId = forOxoDocument.ProgrammeId });
                HttpContext.Current.Cache.Add(cacheKey, oxoDocument, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return oxoDocument;
        }
        private static Vehicle GetVehicle(IDataContext context, Vehicle forVehicle, OXODoc forDocument)
        {
            return (Vehicle)context.Vehicle.GetVehicle(new VehicleFilter()
            {
                ProgrammeId = forVehicle.ProgrammeId,
                Gateway = forVehicle.Gateway,
                OxoDocId = forDocument.Id,
            });
        }
        private static Market GetMarket(IDataContext context, Market forMarket, OXODoc forDocument)
        {
            Market market = null;
            var cacheKey = string.Format("Market_{0}", forMarket.Id);
            var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
            if (cachedLookup != null)
            {
                market = (Market)cachedLookup;
            }
            else
            {
                market = context.Market.GetMarket(new VolumeFilter() { MarketId = forMarket.Id, OxoDocId = forDocument.Id, ProgrammeId = forDocument.ProgrammeId });
                if (!(market is EmptyMarket) && market.Id != 0)
                    HttpContext.Current.Cache.Add(cacheKey, market, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return market;
        }
        private static MarketGroup GetMarketGroup(IDataContext context, MarketGroup forMarketGroup, OXODoc forDocument)
        {
            MarketGroup marketGroup = null;
            var cacheKey = string.Format("MarketGroup_{0}", forMarketGroup.Id);
            var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
            if (cachedLookup != null)
            {
                marketGroup = (MarketGroup)cachedLookup;
            }
            else
            {
                marketGroup = context.Market.GetMarketGroup(new VolumeFilter() { MarketGroupId = forMarketGroup.Id, OxoDocId = forDocument.Id, ProgrammeId = forDocument.ProgrammeId });
                if (!(marketGroup is EmptyMarketGroup) && marketGroup.Id != 0)
                    HttpContext.Current.Cache.Add(cacheKey, marketGroup, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return marketGroup;
        }
        private static TakeRateSummary GetVolumeHeader(IDataContext context, TakeRateSummary forHeader)
        {
            TakeRateSummary header = null;
            var cacheKey = string.Format("FdpVolumeHeader_{0}", forHeader.TakeRateId);
            var cachedLookup = HttpContext.Current.Cache.Get(cacheKey);
            if (cachedLookup != null)
            {
                header = (TakeRateSummary)cachedLookup;
            }
            else
            {
                header = context.Volume.GetVolumeHeader(new VolumeFilter() { FdpVolumeHeaderId = forHeader.TakeRateId });
                HttpContext.Current.Cache.Add(cacheKey, header, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }

            // Get the vehicle associated with the import data
            //header.Vehicle = (Vehicle)context.Vehicle.GetVehicle(new VehicleFilter()
            //{
            //    ProgrammeId = header.ProgrammeId,
            //    Gateway = header.Gateway
            //});

            return header;
        }
        private async static Task<PagedResults<TakeRateSummary>> ListVolumeSummary(IDataContext context, Volume forVolume)
        {
            if (forVolume.Document is EmptyOxoDocument)
                return new PagedResults<TakeRateSummary>();

            return await context.Volume.ListTakeRateData(TakeRateFilter.FromVolume(forVolume));
        }
        private static VolumeData ListVolumeData(IDataContext context, Volume forVolume)
        {
            if (forVolume.Document is EmptyOxoDocument)
                return new VolumeData();

            return context.Volume.ListVolumeData(VolumeFilter.FromVolume(forVolume));
        }
        private static IEnumerable<FdpModel> ListAvailableModelsFilteredByMarket(IDataContext context, Volume forVolume)
        {
            IEnumerable<FdpModel> filteredModels = Enumerable.Empty<FdpModel>();

            if (forVolume.Document is EmptyOxoDocument || forVolume.Vehicle is EmptyVehicle)
                return filteredModels;

            filteredModels = forVolume.Vehicle.AvailableModels;
            var identifiers = filteredModels.Select(m => m.Identifier);

            if (!(forVolume.Market is EmptyMarket))
            {
                identifiers = context.Market.ListAvailableModelsByMarket(forVolume.Document, forVolume.Market).Select(m => m.Identifier);
            }
            else if (!(forVolume.MarketGroup is EmptyMarketGroup))
            {
                identifiers = context.Market.ListAvailableModelsByMarketGroup(forVolume.Document, forVolume.MarketGroup).Select(m => m.Identifier);
            }

            filteredModels = forVolume.Vehicle.AvailableModels.Where(m => identifiers.Contains(m.Identifier));

            return filteredModels;
        }

        #endregion

        #region "Private Members"

        private IVolume _volume = new EmptyVolume();

        #endregion
    }
}
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Caching;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class TakeRateViewModel : SharedModelBase
    {
        public TakeRateSummary TakeRate { get; set; }
        public TakeRateDataItem CurrentTakeRateDataItem { get; set; }
        public TakeRateDataItemAction CurrentAction { get; set; }
        public IEnumerable<TakeRateStatus> Statuses { get; set; }
        public PagedResults<TakeRateSummary> TakeRates { get; set; }
        public TakeRateDocument Document { get; set; }
        
        /// <summary>
        /// Initializes a new instance of the <see cref="ForecastComparisonViewModel"/> class.
        /// </summary>
        /// <param name="dataContext">The data context.</param>
        public TakeRateViewModel() : base()
        {
            InitialiseMembers();
        }
        public TakeRateViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<TakeRateViewModel> GetModel(IDataContext context)
        {
            return await GetModel(context, new TakeRateFilter());
        }
        public static async Task<TakeRateViewModel> GetModel(IDataContext context,
                                                             TakeRateFilter filter,
                                                             TakeRateDataItemAction action)
        {
            var model = await GetModel(context, filter);
            model.CurrentAction = action;
            if (action != TakeRateDataItemAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(action.GetType(), action);
            }

            return model;
        }
        public static async Task<TakeRateViewModel> GetModel(IDataContext context, TakeRateFilter filter)
        {
            TakeRateViewModel model = null;
            
            if (filter.Action == TakeRateDataItemAction.TakeRates)
            {
                model = await GetFullAndPartialViewModelForTakeRates(context, filter);
            }
            else if (filter.Action == TakeRateDataItemAction.TakeRateDataPage)
            {
                model = await GetFullAndPartialViewModelForTakeRateDataPage(context, filter);
            }
            //else if (filter.Action == TakeRateDataItemAction.TakeRateData)
            //{
            //    model = await GetFullAndPartialViewModelForTakeRateData(context, filter);
            //}
            else if (filter.Action == TakeRateDataItemAction.TakeRateDataItemDetails || filter.Action == TakeRateDataItemAction.UndoChange)
            {
                model = await GetFullAndPartialViewModelForTakeRateDataItem(context, filter);
            }
     
            return model;
        }

        #region "Private Methods"

        private static async Task<TakeRateViewModel> GetFullAndPartialViewModelForTakeRateDataPage(IDataContext context, TakeRateFilter filter)
        {
            var modelBase = GetBaseModel(context);
            var takeRateModel = new TakeRateViewModel(modelBase)
            {
                Document = (TakeRateDocument)TakeRateDocument.FromFilter(filter),
                Configuration = context.ConfigurationSettings
            };

            await HydrateOxoDocument(context, takeRateModel);
            await HydrateFdpVolumeHeaders(context, takeRateModel);
            await HydrateFdpVolumeHeadersFromOxoDocument(context, takeRateModel);
            await HydrateVehicle(context, takeRateModel);
            await HydrateMarket(context, takeRateModel);
            await HydrateMarketGroup(context, takeRateModel);
            await HydrateDerivativesByMarket(context, takeRateModel);
            await HydrateData(context, takeRateModel);

            return takeRateModel;
        }

        //private static async Task<TakeRateViewModel> GetFullAndPartialViewModelForTakeRateData(IDataContext context, TakeRateFilter filter)
        //{
        //    var modelBase = GetBaseModel(context);
        //    var takeRateModel = new TakeRateViewModel(modelBase)
        //    {
        //        Document = (TakeRateDocument)TakeRateDocument.FromFilter(filter),
        //        Configuration = context.ConfigurationSettings
        //        //Countries = context.References.ListReferencesByKey(countryKey)
        //    };

        //    await HydrateOxoDocument(context, takeRateModel);
        //    await HydrateFdpVolumeHeaders(context, takeRateModel);
        //    await HydrateFdpVolumeHeadersFromOxoDocument(context, takeRateModel);
        //    await HydrateVehicle(context, takeRateModel);
        //    await HydrateMarket(context, takeRateModel);
        //    await HydrateMarketGroup(context, takeRateModel);
        //    await HydrateDerivativesByMarket(context, takeRateModel);
        //    await HydrateData(context, takeRateModel);

        //    return takeRateModel;
        //}
        private static async Task<TakeRateViewModel> GetFullAndPartialViewModelForTakeRateDataItem(IDataContext context, TakeRateFilter filter)
        {
            var takeRateModel = new TakeRateViewModel(SharedModelBase.GetBaseModel(context))
            {
                Document = (TakeRateDocument)TakeRateDocument.FromFilter(filter),
                Configuration = context.ConfigurationSettings
            };
            takeRateModel.CurrentTakeRateDataItem = await context.TakeRate.GetDataItem(filter);

            await HydrateOxoDocument(context, takeRateModel);
            await HydrateVehicle(context, takeRateModel);
            await HydrateMarket(context, takeRateModel);
            await HydrateMarketGroup(context, takeRateModel);
            await HydrateDerivativesByMarket(context, takeRateModel);
            await HydrateFeatures(context, takeRateModel);
            await HydrateCurrentModel(context, takeRateModel);
            await HydrateCurrentFeature(context, takeRateModel);

            return takeRateModel;
        }
        private static async Task<TakeRateViewModel> GetFullAndPartialViewModelForTakeRates(IDataContext context, TakeRateFilter filter)
        {
            var model = new TakeRateViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings
            };
            model.TakeRates = await context.TakeRate.ListTakeRateDocuments(filter);
            model.Statuses = await context.TakeRate.ListTakeRateStatuses();

            return model;
        }
        private static async Task<IVehicle> GetVehicle(IDataContext context, Vehicle forVehicle, OXODoc forDocument)
        {
            return await context.Vehicle.GetVehicle(new VehicleFilter()
            {
                ProgrammeId = forVehicle.ProgrammeId,
                Gateway = forVehicle.Gateway,
                OxoDocId = forDocument.Id,
            });
        }
        private static async Task<Market> GetMarket(IDataContext context, Market forMarket, OXODoc forDocument)
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
                market = await Task.FromResult(context.Market.GetMarket(new TakeRateFilter() { MarketId = forMarket.Id, OxoDocId = forDocument.Id, ProgrammeId = forDocument.ProgrammeId }));
                if (!(market is EmptyMarket) && market.Id != 0)
                    HttpContext.Current.Cache.Add(cacheKey, market, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return market;
        }
        private static async Task<MarketGroup> GetMarketGroup(IDataContext context, MarketGroup forMarketGroup, OXODoc forDocument)
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
                marketGroup = await Task.FromResult(context.Market.GetMarketGroup(new TakeRateFilter() { MarketGroupId = forMarketGroup.Id, OxoDocId = forDocument.Id, ProgrammeId = forDocument.ProgrammeId }));
                if (!(marketGroup is EmptyMarketGroup) && marketGroup.Id != 0)
                    HttpContext.Current.Cache.Add(cacheKey, marketGroup, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return marketGroup;
        }
        private static async Task<OXODoc> GetOxoDocument(IDataContext context, OXODoc forOxoDocument)
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
                oxoDocument = await context.TakeRate.GetUnderlyingOxoDocument(new TakeRateFilter() { OxoDocId = forOxoDocument.Id, ProgrammeId = forOxoDocument.ProgrammeId });
                HttpContext.Current.Cache.Add(cacheKey, oxoDocument, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return oxoDocument;
        }
        private static async Task<TakeRateSummary> GetTakeRateDocumentHeader(IDataContext context, TakeRateSummary forHeader)
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
                header = await context.TakeRate.GetTakeRateDocumentHeader(new TakeRateFilter() { OxoDocId = forHeader.OxoDocId });
                HttpContext.Current.Cache.Add(cacheKey, header, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
            }
            return header;
        }
        private static async Task<Market> HydrateMarket(IDataContext context, TakeRateViewModel volumeModel)
        {
            if (volumeModel.Document.Market is EmptyMarket)
                return volumeModel.Document.Market;

            volumeModel.Document.Market = await GetMarket(context, volumeModel.Document.Market, volumeModel.Document.UnderlyingOxoDocument);

            return volumeModel.Document.Market;
        }
        private static async Task<MarketGroup> HydrateMarketGroup(IDataContext context, TakeRateViewModel volumeModel)
        {
            if (volumeModel.Document.MarketGroup is EmptyMarketGroup)
                return volumeModel.Document.MarketGroup;

            volumeModel.Document.MarketGroup = await GetMarketGroup(context, volumeModel.Document.MarketGroup, volumeModel.Document.UnderlyingOxoDocument);

            return volumeModel.Document.MarketGroup;
        }
        private static async Task<IEnumerable<Model>> HydrateDerivativesByMarket(IDataContext context, TakeRateViewModel volumeModel)
        {
            volumeModel.Document.Vehicle.AvailableModels = await ListAvailableModelsFilteredByMarket(context, volumeModel.Document);

            return volumeModel.Document.Vehicle.AvailableModels;
        }
        private static async Task<FdpModel> HydrateCurrentModel(IDataContext context, TakeRateViewModel takeRateModel) {

            FdpModel model = new EmptyFdpModel();

            if (takeRateModel.CurrentTakeRateDataItem.ModelId.HasValue) 
            {
                model = takeRateModel.Document.Vehicle.AvailableModels
                    .Where(m => m.Id == takeRateModel.CurrentTakeRateDataItem.ModelId.Value)
                    .First();
            } 
            else 
            {
                model = takeRateModel.Document.Vehicle.AvailableModels
                    .Where(m => m.FdpModelId == takeRateModel.CurrentTakeRateDataItem.FdpModelId.Value)
                    .First();
            }
            takeRateModel.CurrentTakeRateDataItem.Model = model;

            return await Task.FromResult(model);
        }
        private static async Task<FdpFeature> HydrateCurrentFeature(IDataContext context, TakeRateViewModel takeRateModel) {

            FdpFeature feature = new EmptyFdpFeature();

            if (takeRateModel.CurrentTakeRateDataItem.FeatureId.HasValue) 
            {
                feature = takeRateModel.Document.Vehicle.AvailableFeatures
                    .Where(f => f.Id == takeRateModel.CurrentTakeRateDataItem.FeatureId.Value)
                    .First();
            } 
            else 
            {
                feature = takeRateModel.Document.Vehicle.AvailableFeatures
                    .Where(f => f.FdpFeatureId == takeRateModel.CurrentTakeRateDataItem.FdpFeatureId.Value)
                    .First();
            }
            takeRateModel.CurrentTakeRateDataItem.Feature = feature;

            return await Task.FromResult(feature);
        }
        private static async Task<IEnumerable<TakeRateSummary>> HydrateFdpVolumeHeaders(IDataContext context, TakeRateViewModel volumeModel)
        {
            var volumeSummary = new List<TakeRateSummary>();
            foreach (var header in volumeModel.Document.TakeRateSummary)
            {
                var newHeader = await GetTakeRateDocumentHeader(context, header);
                //volumeSummary.Add(newHeader);
                //volumeModel.Volume.Vehicle.AvailableImports = newHeader.Vehicle.AvailableImports;
                //volumeModel.Volume.Vehicle.AvailableDocuments = newHeader.Vehicle.AvailableDocuments;
            }

            volumeModel.Document.TakeRateSummary = volumeSummary;

            return volumeSummary;
        }
        private async static Task HydrateFdpVolumeHeadersFromOxoDocument(IDataContext context, TakeRateViewModel volumeModel)
        {
            if (volumeModel.Document.TakeRateSummary.Any())
                return;

            var volumeHeaders = await ListVolumeSummary(context, volumeModel.Document);
            volumeModel.Document.TakeRateSummary = volumeHeaders.CurrentPage;
        }
        private static async Task<OXODoc> HydrateOxoDocument(IDataContext context, TakeRateViewModel volumeModel)
        {
            volumeModel.Document.UnderlyingOxoDocument = await GetOxoDocument(context, volumeModel.Document.UnderlyingOxoDocument);

            volumeModel.Document.Vehicle.ProgrammeId = volumeModel.Document.UnderlyingOxoDocument.ProgrammeId;
            volumeModel.Document.Vehicle.Gateway = volumeModel.Document.UnderlyingOxoDocument.Gateway;

            return volumeModel.Document.UnderlyingOxoDocument;
        }
        private static async Task<TakeRateData> HydrateData(IDataContext context, TakeRateViewModel takeRateModel)
        {
            takeRateModel.Document.TakeRateData = await ListTakeRateData(context, takeRateModel.Document);
            return takeRateModel.Document.TakeRateData;
        }
        private static async Task<IVehicle> HydrateVehicle(IDataContext context, TakeRateViewModel volumeModel)
        {
            if (!(volumeModel.Document.Vehicle is EmptyVehicle))
                return volumeModel.Document.Vehicle;

            volumeModel.Document.Vehicle = (Vehicle)(await GetVehicle(context, volumeModel.Document.Vehicle, volumeModel.Document.UnderlyingOxoDocument));
            // Set this prior to filtering by market
            volumeModel.Document.TotalDerivatives = volumeModel.Document.Vehicle.AvailableModels.Count();

            return volumeModel.Document.Vehicle;
        }
        private static async Task<IEnumerable<FdpFeature>> HydrateFeatures(IDataContext context, TakeRateViewModel takeRateModel) 
        {
            takeRateModel.Document.Vehicle.AvailableFeatures = await ListFeatures(context, takeRateModel.Document);
            return takeRateModel.Document.Vehicle.AvailableFeatures;
        }
        private void InitialiseMembers()
        {
            TakeRate = new EmptyTakeRateSummary();
            TakeRates = new PagedResults<TakeRateSummary>();
            Statuses = Enumerable.Empty<TakeRateStatus>();
            CurrentTakeRateDataItem = new EmptyTakeRateDataItem();
            CurrentAction = TakeRateDataItemAction.NotSet;
            IdentifierPrefix = "Page";
            Document = new EmptyTakeRateDocument();
        }
        private static async Task<IEnumerable<FdpModel>> ListAvailableModelsFilteredByMarket(IDataContext context, TakeRateDocument forVolume)
        {
            IEnumerable<FdpModel> filteredModels = Enumerable.Empty<FdpModel>();

            if (forVolume.UnderlyingOxoDocument is EmptyOxoDocument || forVolume.Vehicle is EmptyVehicle)
                return filteredModels;

            var filter = new ProgrammeFilter()
            {
                ProgrammeId = forVolume.UnderlyingOxoDocument.ProgrammeId,
                Gateway = forVolume.UnderlyingOxoDocument.Gateway,
                OxoDocId = forVolume.UnderlyingOxoDocument.Id
            };

            if (!(forVolume.Market is EmptyMarket))
            {
                filteredModels = (await context.Market.ListAvailableModelsByMarket(filter, forVolume.Market))
                    .Where(m => m.Available == true);
            }
            else if (!(forVolume.MarketGroup is EmptyMarketGroup))
            {
                filteredModels = (await context.Market.ListAvailableModelsByMarketGroup(filter, forVolume.MarketGroup))
                    .Where(m => m.Available == true);
            }
            else
            {
                filteredModels = forVolume.Vehicle.AvailableModels;
            }

            return filteredModels;
        }
        private async static Task<IEnumerable<FdpFeature>> ListFeatures(IDataContext context, TakeRateDocument forDocument)
        {
            if (forDocument.UnderlyingOxoDocument is EmptyOxoDocument)
                return Enumerable.Empty<FdpFeature>();

            return await context.Vehicle.ListFeatures(FeatureFilter.FromOxoDocumentId(forDocument.UnderlyingOxoDocument.Id));
        }
        private async static Task<TakeRateData> ListTakeRateData(IDataContext context, TakeRateDocument forDocument)
        {
            if (forDocument.UnderlyingOxoDocument is EmptyOxoDocument)
                return new TakeRateData();

            return await context.TakeRate.GetTakeRateDocumentData(TakeRateFilter.FromTakeRateDocument(forDocument));
        }
        private async static Task<PagedResults<TakeRateSummary>> ListVolumeSummary(IDataContext context, TakeRateDocument forVolume)
        {
            if (forVolume.UnderlyingOxoDocument is EmptyOxoDocument)
                return new PagedResults<TakeRateSummary>();

            return await context.TakeRate.ListTakeRateDocuments(TakeRateFilter.FromTakeRateDocument(forVolume));
        }

        #endregion
    }
}

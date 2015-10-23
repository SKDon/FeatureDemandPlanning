using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class ImportViewModel : SharedModelBase
    {
        #region "Public Properties"

        public ImportQueue CurrentImport { get; set; }
        public ImportError CurrentException { get; set; }
        public DerivativeMapping CurrentDerivativeMapping { get; set; }
        public TrimMapping CurrentTrimMapping { get; set; }
        public ImportExceptionAction CurrentAction { get; set; }
        public string CurrentFeatureGroup { get; set; }
        public FeatureGroup CurrentFeatureSubGroup { get; set; }
        public Feature CurrentFeature { get; set; }
        public Market CurrentMarket { get; set; }

        public PagedResults<ImportError> Exceptions { get; set; }
        public PagedResults<ImportQueue> ImportQueue { get; set; }

        public Programme Programme { get; set; }
        public string Gateway { get; set; }

        public IEnumerable<ModelEngine> AvailableEngines { get; set; }
        public IEnumerable<ModelTransmission> AvailableTransmissions { get; set; }
        public IEnumerable<ModelBody> AvailableBodies { get; set; }
        public IEnumerable<ModelTrim> AvailableTrim { get; set; }
        public IEnumerable<SpecialFeature> AvailableSpecialFeatures { get; set; }
        public IEnumerable<Market> AvailableMarkets { get; set; }
        public IEnumerable<Feature> AvailableFeatures { get; set; }
        public IEnumerable<FeatureGroup> AvailableFeatureGroups { get; set; }
        
        public dynamic Configuration { get; set; }

        #endregion

        #region "Constructors"

        public ImportViewModel(IDataContext dataContext) : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
            InitialiseMembers();
        }

        #endregion

        #region "Public Members"

        public IEnumerable<string> FeatureGroups
        {
            get
            {
                return AvailableFeatureGroups.Select(g => g.FeatureGroupName).Distinct().OrderBy(g => g);
            }
        }
        public IEnumerable<FeatureGroup> FeatureSubGroups
        {
            get 
            {
                return AvailableFeatureGroups
                    .Where(g => string.IsNullOrEmpty(CurrentFeatureGroup) ||
                        g.FeatureGroupName.Equals(CurrentFeatureGroup, StringComparison.InvariantCultureIgnoreCase))
                    .OrderBy(g => g.FeatureSubGroup);
            }
        }
        public IEnumerable<Feature> Features
        {
            get
            {
                return AvailableFeatures
                    .Where(f => CurrentFeatureSubGroup is EmptyFeatureGroup ||
                        (f.FeatureGroup.Equals(CurrentFeatureSubGroup.FeatureGroupName, StringComparison.InvariantCultureIgnoreCase) &&
                         f.FeatureSubGroup.Equals(CurrentFeatureSubGroup.FeatureSubGroup, StringComparison.InvariantCultureIgnoreCase)))
                    .OrderBy(f => f.BrandDescription);
            }
        }
        public static async Task<ImportViewModel> GetFullAndPartialViewModel(IDataContext context)
        {
            return await GetFullAndPartialViewModel(context, new ImportQueueFilter());
        }
        public static async Task<ImportViewModel> GetFullAndPartialViewModel(IDataContext context, 
                                                                             ImportQueueFilter filter, 
                                                                             ImportExceptionAction action)
        {
            var model = await GetFullAndPartialViewModel(context, filter);
            model.CurrentAction = action;

            return model;
        }
        public static async Task<ImportViewModel> GetFullAndPartialViewModel(IDataContext context, 
                                                                             ImportQueueFilter filter)
        {
            if (filter.ImportQueueId.HasValue)
            {
                return await GetFullAndPartialViewModelForImportQueueItem(context, filter);
            }
            if (filter.ExceptionId.HasValue)
            {
                return await GetFullAndPartialViewModelForException(context, filter);
            }
            return await GetFullAndPartialViewModelForImportQueue(context, filter);
        }

        #endregion

        #region "Private Members"

        private static async Task<ImportViewModel> GetFullAndPartialViewModelForImportQueue(IDataContext context,
                                                                                            ImportQueueFilter filter)
        {
            var model = new ImportViewModel(context)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue
            };
            model.ImportQueue = await context.Import.ListImportQueue(filter);
            model.TotalPages = model.ImportQueue.TotalPages;
            model.TotalRecords = model.ImportQueue.TotalRecords;
            model.TotalDisplayRecords = model.ImportQueue.TotalDisplayRecords;

            return model;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForException(IDataContext context,
                                                                                          ImportQueueFilter filter)
        {
            var model = new ImportViewModel(context)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue
            };
            model.CurrentException = await context.Import.GetException(filter);

            var programmeFilter = new ProgrammeFilter(model.CurrentException.ProgrammeId);

            model.Programme = context.Vehicle.GetProgramme(programmeFilter);
            programmeFilter.VehicleId = model.Programme.VehicleId;

            model.Gateway = model.CurrentException.Gateway;
            model.AvailableEngines = context.Vehicle.ListEngines(programmeFilter);
            model.AvailableTransmissions = context.Vehicle.ListTransmissions(programmeFilter);
            model.AvailableBodies = context.Vehicle.ListBodies(programmeFilter);
            model.AvailableTrim = context.Vehicle.ListTrim(programmeFilter);
            model.AvailableSpecialFeatures = context.Volume.ListSpecialFeatures(programmeFilter);
            model.AvailableMarkets = context.Market.ListAvailableMarkets(programmeFilter);
            model.AvailableFeatures = context.Vehicle.ListFeatures(programmeFilter);
            model.AvailableFeatureGroups = context.Vehicle.ListFeatureGroups(programmeFilter);

            return model;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForImportQueueItem(IDataContext context,
                                                                                                ImportQueueFilter filter)
        {
            var model = new ImportViewModel(context)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue
            };
            model.CurrentImport = await context.Import.GetImportQueue(filter);

            var programmeFilter = new ProgrammeFilter(model.CurrentImport.ProgrammeId);
            model.Exceptions = await context.Import.ListExceptions(filter);
            model.TotalPages = model.Exceptions.TotalPages;
            model.TotalRecords = model.Exceptions.TotalRecords;
            model.TotalDisplayRecords = model.Exceptions.TotalDisplayRecords;
            model.Programme = context.Vehicle.GetProgramme(programmeFilter);
            model.Gateway = model.CurrentImport.Gateway;

            return model;
        }

        private void InitialiseMembers()
        {
 	        CurrentImport = new EmptyImportQueue();
            CurrentException = new EmptyImportError();
            CurrentDerivativeMapping = new EmptyDerivativeMapping();
            CurrentTrimMapping = new EmptyTrimMapping();
            CurrentAction = ImportExceptionAction.NotSet;
            CurrentFeatureGroup = string.Empty;
            CurrentFeature = new EmptyFeature();
            CurrentMarket = new EmptyMarket();

            AvailableEngines = Enumerable.Empty<ModelEngine>();
            AvailableTransmissions = Enumerable.Empty<ModelTransmission>();
            AvailableBodies = Enumerable.Empty<ModelBody>();
            AvailableTrim = Enumerable.Empty<ModelTrim>();
            AvailableSpecialFeatures  = Enumerable.Empty<SpecialFeature>();
            AvailableMarkets = Enumerable.Empty<Market>();
            AvailableFeatures = Enumerable.Empty<Feature>();
            AvailableFeatureGroups = Enumerable.Empty<FeatureGroup>();
        }

        #endregion
    }
}
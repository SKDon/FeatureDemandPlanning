using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Caching;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ImportViewModel : SharedModelBase
    {
        #region "Public Properties"

        public ImportQueue CurrentImport { get; set; }
        public ImportError CurrentException { get; set; }
        public enums.ImportAction CurrentAction { get; set; }
        public enums.ImportAction CurrentImportAction { get; set; }
        public string CurrentFeatureGroup { get; set; }
        public FeatureGroup CurrentFeatureSubGroup { get; set; }
        public Feature CurrentFeature { get; set; }
        public Market CurrentMarket { get; set; }
        public Programme CurrentProgramme { get; set; }

        public PagedResults<ImportError> Exceptions { get; set; }
        public PagedResults<ImportQueue> ImportQueue { get; set; }
        public ImportSummary Summary { get; set; }

        public OXODoc Document { get; set; }
        public Programme Programme { get; set; }
        public string Gateway { get; set; }

        public IEnumerable<Programme> AvailableProgrammes { get; set; }
        public IEnumerable<OXODoc> AvailableDocuments { get; set; }
        public IEnumerable<ModelEngine> AvailableEngines { get; set; }
        public IEnumerable<ModelTransmission> AvailableTransmissions { get; set; }
        public IEnumerable<ModelBody> AvailableBodies { get; set; }
        public IEnumerable<OxoTrim> AvailableTrim { get; set; }
        public IEnumerable<SpecialFeature> AvailableSpecialFeatures { get; set; }
        public IEnumerable<Market> AvailableMarkets { get; set; }
        public IEnumerable<FdpFeature> AvailableFeatures { get; set; }
        public IEnumerable<FeatureGroup> AvailableFeatureGroups { get; set; }
        public IEnumerable<Derivative> AvailableDerivatives { get; set; }
        public IEnumerable<ImportExceptionType> AvailableExceptionTypes { get; set; }
        public IEnumerable<ImportStatus> AvailableImportStatuses { get; set; }
        public IEnumerable<TrimLevel> AvailableTrimLevels { get; set; }
        public IEnumerable<ImportDerivative> AvailableImportDerivatives { get; set; }
        public IEnumerable<ImportTrim> AvailableImportTrimLevels { get; set; }
        public IEnumerable<ImportFeature> AvailableImportFeatures { get; set; } 

        #endregion

        #region "Constructors"

        public ImportViewModel()
        {
            InitialiseMembers();
        }
        public ImportViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }

        #endregion

        #region "Public Members"

        public IEnumerable<CarLine> CarLines
        {
            get
            {
                return AvailableProgrammes.ListCarLines();
            }
        }
        public IEnumerable<Gateway> Gateways
        {
            get
            {
                return AvailableProgrammes.Select(p => new Gateway
                {
                        VehicleName = p.VehicleName,
                        Name = p.Gateway,
                        ModelYear = p.ModelYear
                    })
                    .Distinct(new GatewayComparer())
                    .OrderBy(p => p.Name);
            }
        }
        public IEnumerable<OXODoc> Documents
        {
            get
            {
                return AvailableDocuments;
            }
        }
        public IEnumerable<ImportStatus> ImportStatuses
        {
            get {
                return AvailableImportStatuses
                    .Where(s => s.ImportStatusCode != enums.ImportStatus.NotSet)
                    .OrderBy(s => s.Status);
            }
        }

        public IEnumerable<ModelYear> ModelYears
        {
            get
            {
                return AvailableProgrammes.Select(p => new ModelYear
                {
                        VehicleName = p.VehicleName,
                        Name = p.ModelYear
                    })
                    .Distinct(new ModelYearComparer());
            }
        }

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
        public bool HasExceptions()
        {
            return Exceptions != null && Exceptions.CurrentPage.Any();
        }
        public bool HasExceptions(enums.ImportExceptionType ofType)
        {
            return HasExceptions() && Exceptions.CurrentPage.Where(e => e.ErrorType == ofType).Any();
        }
        public static async Task<ImportViewModel> GetModel(IDataContext context)
        {
            return await GetModel(context, new ImportQueueFilter());
        }
        public static async Task<ImportViewModel> GetModel(IDataContext context, 
                                                           ImportQueueFilter filter,
                                                           enums.ImportAction action)
        {
            var model = await GetModel(context, filter);
            model.CurrentAction = action;
            if (action != enums.ImportAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(action.GetType(), action);
            }

            return model;
        }
        public static async Task<ImportViewModel> GetModel(IDataContext context, 
                                                           ImportQueueFilter filter)
        {
            ImportViewModel model = null;

            switch (filter.Action)
            {
                case enums.ImportAction.ImportQueue:
                    model = await GetFullAndPartialViewModelForImportQueue(context, filter);
                    break;
                case enums.ImportAction.Exception:
                    model = await GetFullAndPartialViewModelForException(context, filter);
                    break;
                case enums.ImportAction.ImportQueueItem:
                case enums.ImportAction.ProcessTakeRateData:
                case enums.ImportAction.DeleteImport:
                    model = await GetFullAndPartialViewModelForImportQueueItem(context, filter);
                    break;
                case enums.ImportAction.Summary:
                    model = await GetFullAndPartialViewModelForSummary(context, filter);
                    break;
                default:
                    model = await GetFullAndPartialViewModel(context);
                    break;
            }
            return model;
        }

        #endregion

        #region "Private Members"

        private static async Task<ImportViewModel> GetFullAndPartialViewModel(IDataContext context)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
                AvailableProgrammes = await
                    Task.FromResult(context.Vehicle.ListProgrammes(new ProgrammeFilter())),
                AvailableDocuments = await
                    Task.FromResult(context.Vehicle.ListPublishedDocuments(new ProgrammeFilter())),
                AvailableImportStatuses = await context.Import.ListImportStatuses()
            };

            model.AvailableDocuments = context.Vehicle.ListPublishedDocuments(new ProgrammeFilter());

            return model;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForImportQueue(IDataContext context,
                                                                                            ImportQueueFilter filter)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                PageIndex = filter.PageIndex ?? 1,
                PageSize = filter.PageSize ?? int.MaxValue,
                Configuration = context.ConfigurationSettings,
                ImportQueue = await context.Import.ListImportQueue(filter)
            };
            model.TotalPages = model.ImportQueue.TotalPages;
            model.TotalRecords = model.ImportQueue.TotalRecords;
            model.TotalDisplayRecords = model.ImportQueue.TotalDisplayRecords;

            model.AvailableProgrammes = context.Vehicle.ListProgrammes(new ProgrammeFilter());
            model.AvailableDocuments = context.Vehicle.ListPublishedDocuments(new ProgrammeFilter());

            return model;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForException(IDataContext context,
                                                                                          ImportQueueFilter filter)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                PageIndex = filter.PageIndex ?? 1,
                PageSize = filter.PageSize ?? int.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentException = await context.Import.GetException(filter)
            };

            var programmeFilter = new ProgrammeFilter(model.CurrentException.ProgrammeId) { DocumentId = model.CurrentException.DocumentId };
            var featureFilter = new FeatureFilter { ProgrammeId = model.CurrentException.ProgrammeId, DocumentId = model.CurrentException.DocumentId };
            
            model.Programme = context.Vehicle.GetProgramme(programmeFilter);
            programmeFilter.VehicleId = model.Programme.VehicleId;

            model.Gateway = model.CurrentException.Gateway;
            model.AvailableDocuments = context.Vehicle.ListPublishedDocuments(programmeFilter);
            model.AvailableEngines = context.Vehicle.ListEngines(programmeFilter);
            model.AvailableTransmissions = context.Vehicle.ListTransmissions(programmeFilter);
            model.AvailableBodies = context.Vehicle.ListBodies(programmeFilter);
            model.AvailableSpecialFeatures = await context.TakeRate.ListSpecialFeatures(programmeFilter);
            model.AvailableMarkets = await context.Market.ListAvailableMarkets();
            model.AvailableFeatures = await context.Vehicle.ListFeatures(featureFilter);
            model.AvailableFeatureGroups = context.Vehicle.ListFeatureGroups(programmeFilter);
            model.AvailableTrimLevels = context.Vehicle.ListTrimLevels(programmeFilter);

            var derivativeFilter = new DerivativeFilter
            {
                CarLine = model.Programme.VehicleName,
                ModelYear = model.Programme.ModelYear,
                Gateway = model.Gateway,
                ProgrammeId = model.CurrentException.ProgrammeId,
            };

            model.AvailableDerivatives = context.Vehicle.ListDerivatives(derivativeFilter);
            model.AvailableImportDerivatives = await ListImportDerivatives(model.CurrentException.ImportQueueId, context);
            model.AvailableImportTrimLevels = await ListImportTrimLevels(model.CurrentException.ImportQueueId, context);
            model.AvailableImportFeatures = await ListImportFeatures(model.CurrentException.ImportQueueId, context);

            derivativeFilter.Bmc = model.CurrentException.ImportDerivativeCode;
           
            var trimFilter = new TrimMappingFilter
            {
                CarLine = model.Programme.VehicleName,
                ModelYear = model.Programme.ModelYear,
                Gateway = model.Gateway,
                DocumentId = model.CurrentException.DocumentId,
                IncludeAllTrim = false
            };
            model.AvailableTrim = (await context.Vehicle.ListOxoTrim(trimFilter)).CurrentPage;
            model.Document = model.AvailableDocuments.FirstOrDefault(d => d.Id == model.CurrentException.DocumentId);

            return model;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForImportQueueItem(IDataContext context,
                                                                                                ImportQueueFilter filter)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                PageIndex = filter.PageIndex ?? 1,
                PageSize = filter.PageSize ?? int.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentImport = await context.Import.GetImportQueue(filter),
                AvailableExceptionTypes = await context.Import.ListExceptionTypes(filter)
            };

            var programmeFilter = new ProgrammeFilter(model.CurrentImport.ProgrammeId)
            {
                DocumentId = model.CurrentImport.DocumentId
            };
            model.AvailableDocuments = context.Vehicle.ListPublishedDocuments(programmeFilter);
            model.Exceptions = await context.Import.ListExceptions(filter);
            model.TotalPages = model.Exceptions.TotalPages;
            model.TotalRecords = model.Exceptions.TotalRecords;
            model.TotalDisplayRecords = model.Exceptions.TotalDisplayRecords;
            model.Document = model.AvailableDocuments.FirstOrDefault(d => d.Id == programmeFilter.DocumentId);
            model.Programme = context.Vehicle.GetProgramme(programmeFilter);
            model.Gateway = model.CurrentImport.Gateway;
            model.Summary = await context.Import.GetImportSummary(filter);

            return model;
        }
        private static async Task<IEnumerable<ImportDerivative>> ListImportDerivatives(int importQueueId, IDataContext context)
        {
            var cacheKey = string.Format("ImportDerivatives_{0}", importQueueId);
            var derivatives = (IEnumerable<ImportDerivative>)HttpContext.Current.Cache.Get(cacheKey);
            if (derivatives != null)
            {
                return derivatives;
            }

            derivatives = await context.Import.ListImportDerivatives(new ImportQueueFilter(importQueueId));
            if (derivatives != null)
            {
                HttpContext.Current.Cache.Insert(cacheKey, derivatives, null, DateTime.Now.AddMinutes(10), Cache.NoSlidingExpiration);
            }
            return derivatives;
        }
        private static async Task<IEnumerable<ImportTrim>> ListImportTrimLevels(int importQueueId, IDataContext context)
        {
            var cacheKey = string.Format("ImportTrimLevels_{0}", importQueueId);
            var trimLevels = (IEnumerable<ImportTrim>) HttpContext.Current.Cache.Get(cacheKey);
            if (trimLevels != null)
            {
                return trimLevels;
            }

            trimLevels = await context.Import.ListImportTrimLevels(new ImportQueueFilter(importQueueId));
            if (trimLevels != null)
            {
                HttpContext.Current.Cache.Insert(cacheKey, trimLevels, null, DateTime.Now.AddMinutes(10), Cache.NoSlidingExpiration);
            }
            return trimLevels;
        }
        private static async Task<IEnumerable<ImportFeature>> ListImportFeatures(int importQueueId, IDataContext context)
        {
            var cacheKey = string.Format("ImportFeatures_{0}", importQueueId);
            var features = (IEnumerable<ImportFeature>)HttpContext.Current.Cache.Get(cacheKey);
            if (features != null)
            {
                return features;
            }

            features = await context.Import.ListImportFeatures(new ImportQueueFilter(importQueueId));
            if (features != null)
            {
                HttpContext.Current.Cache.Insert(cacheKey, features, null, DateTime.Now.AddMinutes(10), Cache.NoSlidingExpiration);
            }
            return features;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForSummary(IDataContext context, ImportQueueFilter filter)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                Summary = await context.Import.GetImportSummary(filter)
            };

            return model;
        }

        private void InitialiseMembers()
        {
 	        CurrentImport = new EmptyImportQueue();
            CurrentException = new EmptyImportError();
            CurrentAction = enums.ImportAction.NotSet;
            CurrentFeatureGroup = string.Empty;
            CurrentFeatureSubGroup = new EmptyFeatureGroup();
            CurrentFeature = new EmptyFeature();
            CurrentMarket = new EmptyMarket();

            AvailableDocuments = Enumerable.Empty<OXODoc>();
            AvailableEngines = Enumerable.Empty<ModelEngine>();
            AvailableTransmissions = Enumerable.Empty<ModelTransmission>();
            AvailableBodies = Enumerable.Empty<ModelBody>();
            AvailableTrim = Enumerable.Empty<OxoTrim>();
            AvailableSpecialFeatures  = Enumerable.Empty<SpecialFeature>();
            AvailableMarkets = Enumerable.Empty<Market>();
            AvailableFeatures = Enumerable.Empty<FdpFeature>();
            AvailableFeatureGroups = Enumerable.Empty<FeatureGroup>();
            AvailableDerivatives = Enumerable.Empty<Derivative>();
            AvailableImportDerivatives = Enumerable.Empty<ImportDerivative>();
            AvailableImportTrimLevels = Enumerable.Empty<ImportTrim>();
            AvailableExceptionTypes = Enumerable.Empty<ImportExceptionType>();
            AvailableImportStatuses = Enumerable.Empty<ImportStatus>();
            AvailableTrimLevels = Enumerable.Empty<TrimLevel>();

            IdentifierPrefix = "Page";
        }

        #endregion
    }
}
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using enums = FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ImportViewModel : SharedModelBase
    {
        #region "Public Properties"

        public ImportQueue CurrentImport { get; set; }
        public ImportError CurrentException { get; set; }
        public DerivativeMapping CurrentDerivativeMapping { get; set; }
        public TrimMapping CurrentTrimMapping { get; set; }
        public ImportAction CurrentAction { get; set; }
        public ImportAction CurrentImportAction { get; set; }
        public string CurrentFeatureGroup { get; set; }
        public FeatureGroup CurrentFeatureSubGroup { get; set; }
        public Feature CurrentFeature { get; set; }
        public Market CurrentMarket { get; set; }
        public Programme CurrentProgramme { get; set; }

        public PagedResults<ImportError> Exceptions { get; set; }
        public PagedResults<ImportQueue> ImportQueue { get; set; }

        public Programme Programme { get; set; }
        public string Gateway { get; set; }

        public IEnumerable<Programme> AvailableProgrammes { get; set; }
        public IEnumerable<ModelEngine> AvailableEngines { get; set; }
        public IEnumerable<ModelTransmission> AvailableTransmissions { get; set; }
        public IEnumerable<ModelBody> AvailableBodies { get; set; }
        public IEnumerable<ModelTrim> AvailableTrim { get; set; }
        public IEnumerable<SpecialFeature> AvailableSpecialFeatures { get; set; }
        public IEnumerable<Market> AvailableMarkets { get; set; }
        public IEnumerable<Feature> AvailableFeatures { get; set; }
        public IEnumerable<FeatureGroup> AvailableFeatureGroups { get; set; }
        public IEnumerable<Derivative> AvailableDerivatives { get; set; }
        public IEnumerable<ImportExceptionType> AvailableExceptionTypes { get; set; }
        public IEnumerable<ImportStatus> AvailableImportStatuses { get; set; }

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
                return AvailableProgrammes.Select(p => new Gateway()
                    {
                        VehicleName = p.VehicleName,
                        Name = p.Gateway
                    })
                    .Distinct(new GatewayComparer())
                    .OrderBy(p => p.Name);
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
                return AvailableProgrammes.Select(p => new ModelYear()
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
            return HasExceptions() && Exceptions.CurrentPage.Any(e => e.ErrorType == ofType);
        }
        public static async Task<ImportViewModel> GetModel(IDataContext context)
        {
            return await GetModel(context, new ImportQueueFilter());
        }
        public static async Task<ImportViewModel> GetModel(IDataContext context, 
                                                           ImportQueueFilter filter,
                                                           ImportAction action)
        {
            var model = await GetModel(context, filter);
            model.CurrentAction = action;
            if (action != ImportAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(action.GetType(), action);
            }

            return model;
        }
        public static async Task<ImportViewModel> GetModel(IDataContext context, 
                                                           ImportQueueFilter filter)
        {
            ImportViewModel model;

            switch (filter.Action)
            {
                case ImportAction.ImportQueue:
                    model = await GetFullAndPartialViewModelForImportQueue(context, filter);
                    break;
                case ImportAction.Exception:
                    model = await GetFullAndPartialViewModelForException(context, filter);
                    break;
                case ImportAction.ImportQueueItem:
                    model = await GetFullAndPartialViewModelForImportQueueItem(context, filter);
                    break;
                default:
                    model = await GetFullAndPartialViewModel(context, filter);
                    break;
            }
            return model;
        }

        #endregion

        #region "Private Members"

        private static async Task<ImportViewModel> GetFullAndPartialViewModel(IDataContext context,
                                                                              ImportQueueFilter filter)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
                AvailableProgrammes = await
                    Task.FromResult(context.Vehicle.ListProgrammes(new ProgrammeFilter())),
                AvailableImportStatuses = await context.Import.ListImportStatuses()
            };
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
            var programmeFilter = new ProgrammeFilter(model.CurrentException.ProgrammeId);

            model.Programme = context.Vehicle.GetProgramme(programmeFilter);
            programmeFilter.VehicleId = model.Programme.VehicleId;

            model.Gateway = model.CurrentException.Gateway;
            model.AvailableEngines = context.Vehicle.ListEngines(programmeFilter);
            model.AvailableTransmissions = context.Vehicle.ListTransmissions(programmeFilter);
            model.AvailableBodies = context.Vehicle.ListBodies(programmeFilter);
            model.AvailableTrim = context.Vehicle.ListTrim(programmeFilter);
            model.AvailableSpecialFeatures = context.TakeRate.ListSpecialFeatures(programmeFilter);
            model.AvailableMarkets = context.Market.ListAvailableMarkets(programmeFilter);
            model.AvailableFeatures = context.Vehicle.ListFeatures(programmeFilter);
            model.AvailableFeatureGroups = context.Vehicle.ListFeatureGroups(programmeFilter);
            model.AvailableDerivatives = context.Vehicle.ListDerivatives(programmeFilter);

            return model;
        }
        private static async Task<ImportViewModel> GetFullAndPartialViewModelForImportQueueItem(IDataContext context,
                                                                                                ImportQueueFilter filter)
        {
            var model = new ImportViewModel(GetBaseModel(context))
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentImport = await context.Import.GetImportQueue(filter),
                AvailableExceptionTypes = await context.Import.ListExceptionTypes(filter)
            };
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
            CurrentAction = ImportAction.NotSet;
            CurrentFeatureGroup = string.Empty;
            CurrentFeatureSubGroup = new EmptyFeatureGroup();
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
            AvailableDerivatives = Enumerable.Empty<Derivative>();
            AvailableExceptionTypes = Enumerable.Empty<ImportExceptionType>();
            AvailableImportStatuses = Enumerable.Empty<ImportStatus>();

            IdentifierPrefix = "Page";
        }

        #endregion
    }
}
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class MarketMappingViewModel : SharedModelBase
    {
        public MarketMappingAction CurrentAction { get; set; }
        public FdpMarketMapping MarketMapping { get; set; }
        public PagedResults<FdpMarketMapping> MarketMappings { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set;}
       
        public MarketMappingViewModel() : base()
        {
            InitialiseMembers();
        }
        public MarketMappingViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<MarketMappingViewModel> GetModel(IDataContext context,
                                                                      MarketMappingFilter filter)
        {
            MarketMappingViewModel model = null;

            if (filter.Action == MarketMappingAction.Delete 
                || filter.Action == MarketMappingAction.Mapping
                || filter.Action == MarketMappingAction.Copy)
            {
                model = await GetFullAndPartialViewModelForMarketMapping(context, filter);
            }
            else if (filter.Action == MarketMappingAction.Mappings ||
                filter.Action == MarketMappingAction.CopyAll)
            {
                model = await GetFullAndPartialViewModelForMarketMappings(context, filter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, filter);
            }
            if (filter.Action != MarketMappingAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(filter.Action.GetType(), filter.Action);
            }
            return model;
        }
        private static MarketMappingViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                             MarketMappingFilter filter)
        {
            var model = new MarketMappingViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<MarketMappingViewModel> GetFullAndPartialViewModelForMarketMapping
        (
            IDataContext context,
            MarketMappingFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new MarketMappingViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            var marketMapping = await context.Market.GetFdpMarketMapping(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = marketMapping.ProgrammeId,
                Gateway = marketMapping.Gateway,
                Code = model.MarketMapping.Programme.VehicleName // In order to filter the gateways specific to the programme
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            model.Gateways = context.Vehicle.ListGateways(programmeFilter);
            
            if (!(marketMapping is EmptyFdpMarketMapping))
            {
                marketMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == marketMapping.ProgrammeId.GetValueOrDefault());
            }
            model.MarketMapping = marketMapping;
           
            return model;
        }
        private static async Task<MarketMappingViewModel> GetFullAndPartialViewModelForMarketMappings
        (
            IDataContext context,
            MarketMappingFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new MarketMappingViewModel(baseModel)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };

            var programmeFilter = new ProgrammeFilter() {
                ProgrammeId = filter.ProgrammeId,
                Gateway = filter.Gateway
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);

            model.MarketMappings = await context.Market.ListFdpMarketMappings(filter);
            model.TotalPages = model.MarketMappings.TotalPages;
            model.TotalRecords = model.MarketMappings.TotalRecords;
            model.TotalDisplayRecords = model.MarketMappings.TotalDisplayRecords;

            foreach (var marketMapping in model.MarketMappings.CurrentPage)
            {
                marketMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == marketMapping.ProgrammeId.GetValueOrDefault());
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(MarketMappingViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(MarketMappingViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            MarketMapping = new EmptyFdpMarketMapping();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = MarketMappingAction.NotSet;
        }
    }
}

using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class TrimMappingViewModel : SharedModelBase
    {
        public TrimMappingAction CurrentAction { get; set; }
        public FdpTrimMapping TrimMapping { get; set; }
        public PagedResults<FdpTrimMapping> TrimMappings { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set;}
       
        public TrimMappingViewModel() : base()
        {
            InitialiseMembers();
        }
        public TrimMappingViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<TrimMappingViewModel> GetModel(IDataContext context,
                                                                      TrimMappingFilter filter)
        {
            TrimMappingViewModel model = null;

            if (filter.Action == TrimMappingAction.Delete 
                || filter.Action == TrimMappingAction.Mapping
                || filter.Action == TrimMappingAction.Copy)
            {
                model = await GetFullAndPartialViewModelForTrimMapping(context, filter);
            }
            else if (filter.Action == TrimMappingAction.Mappings ||
                filter.Action == TrimMappingAction.CopyAll)
            {
                model = await GetFullAndPartialViewModelForTrimMappings(context, filter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, filter);
            }
            if (filter.Action != TrimMappingAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(filter.Action.GetType(), filter.Action);
            }
            return model;
        }
        private static TrimMappingViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                             TrimMappingFilter filter)
        {
            var model = new TrimMappingViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<TrimMappingViewModel> GetFullAndPartialViewModelForTrimMapping
        (
            IDataContext context,
            TrimMappingFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new TrimMappingViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            var trimMapping = await context.Vehicle.GetFdpTrimMapping(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = trimMapping.ProgrammeId,
                Gateway = trimMapping.Gateway,
                Code = model.TrimMapping.Programme.VehicleName // In order to filter the gateways specific to the programme
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            model.Gateways = context.Vehicle.ListGateways(programmeFilter);
            
            if (!(trimMapping is EmptyFdpTrimMapping))
            {
                trimMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == trimMapping.ProgrammeId);
            }
            model.TrimMapping = trimMapping;
           
            return model;
        }
        private static async Task<TrimMappingViewModel> GetFullAndPartialViewModelForTrimMappings
        (
            IDataContext context,
            TrimMappingFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new TrimMappingViewModel(baseModel)
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

            model.TrimMappings = await context.Vehicle.ListFdpTrimMappings(filter);
            model.TotalPages = model.TrimMappings.TotalPages;
            model.TotalRecords = model.TrimMappings.TotalRecords;
            model.TotalDisplayRecords = model.TrimMappings.TotalDisplayRecords;

            foreach (var trimMapping in model.TrimMappings.CurrentPage)
            {
                trimMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == trimMapping.ProgrammeId);
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(TrimMappingViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(TrimMappingViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            TrimMapping = new EmptyFdpTrimMapping();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = TrimMappingAction.NotSet;
        }
    }
}

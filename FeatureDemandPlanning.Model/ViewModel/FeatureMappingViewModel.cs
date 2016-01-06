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
    public class FeatureMappingViewModel : SharedModelBase
    {
        public FeatureMappingAction CurrentAction { get; set; }
        public FdpFeatureMapping FeatureMapping { get; set; }
        public PagedResults<FdpFeatureMapping> FeatureMappings { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set;}
       
        public FeatureMappingViewModel() : base()
        {
            InitialiseMembers();
        }
        public FeatureMappingViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<FeatureMappingViewModel> GetModel(IDataContext context,
                                                                      FeatureMappingFilter filter)
        {
            FeatureMappingViewModel model;

            if (filter.Action == FeatureMappingAction.Delete 
                || filter.Action == FeatureMappingAction.Mapping
                || filter.Action == FeatureMappingAction.Copy)
            {
                model = await GetFullAndPartialViewModelForFeatureMapping(context, filter);
            }
            else if (filter.Action == FeatureMappingAction.Mappings ||
                filter.Action == FeatureMappingAction.CopyAll)
            {
                model = await GetFullAndPartialViewModelForFeatureMappings(context, filter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, filter);
            }
            if (filter.Action != FeatureMappingAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(filter.Action.GetType(), filter.Action);
            }
            return model;
        }
        private static FeatureMappingViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                             FeatureMappingFilter filter)
        {
            var model = new FeatureMappingViewModel(GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<FeatureMappingViewModel> GetFullAndPartialViewModelForFeatureMapping
        (
            IDataContext context,
            FeatureMappingFilter filter
        )
        {
            var baseModel = GetBaseModel(context);
            var model = new FeatureMappingViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : int.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            var featureMapping = await context.Vehicle.GetFdpFeatureMapping(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = featureMapping.ProgrammeId,
                Gateway = featureMapping.Gateway,
                Code = model.FeatureMapping.Programme.VehicleName // In order to filter the gateways specific to the programme
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            model.Gateways = context.Vehicle.ListGateways(programmeFilter);

            // If we are copying to another gateway, we need to remove the source gateway from the list of available gateways
            if (filter.Action == FeatureMappingAction.Copy)
            {
                model.Gateways = model.Gateways.Where(g => !(g.Name.Equals(featureMapping.Gateway, StringComparison.InvariantCultureIgnoreCase)));
            }
            
            if (!(featureMapping is EmptyFdpFeatureMapping))
            {
                featureMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == featureMapping.ProgrammeId.GetValueOrDefault());
            }
            model.FeatureMapping = featureMapping;
           
            return model;
        }
        private static async Task<FeatureMappingViewModel> GetFullAndPartialViewModelForFeatureMappings
        (
            IDataContext context,
            FeatureMappingFilter filter
        )
        {
            var baseModel = GetBaseModel(context);
            var model = new FeatureMappingViewModel(baseModel)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : int.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };

            var programmeFilter = new ProgrammeFilter() {
                ProgrammeId = filter.ProgrammeId,
                Gateway = filter.Gateway
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);

            model.FeatureMappings = await context.Vehicle.ListFdpFeatureMappings(filter);
            model.TotalPages = model.FeatureMappings.TotalPages;
            model.TotalRecords = model.FeatureMappings.TotalRecords;
            model.TotalDisplayRecords = model.FeatureMappings.TotalDisplayRecords;

            foreach (var featureMapping in model.FeatureMappings.CurrentPage)
            {
                featureMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == featureMapping.ProgrammeId.GetValueOrDefault());
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(FeatureMappingViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(FeatureMappingViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            FeatureMapping = new EmptyFdpFeatureMapping();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = FeatureMappingAction.NotSet;
        }
    }
}

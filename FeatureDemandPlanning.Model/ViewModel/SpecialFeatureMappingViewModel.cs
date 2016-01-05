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
    public class SpecialFeatureMappingViewModel : SharedModelBase
    {
        public SpecialFeatureMappingAction CurrentAction { get; set; }
        public FdpSpecialFeatureMapping SpecialFeatureMapping { get; set; }
        public PagedResults<FdpSpecialFeatureMapping> SpecialFeatureMappings { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set;}
       
        public SpecialFeatureMappingViewModel() : base()
        {
            InitialiseMembers();
        }
        public SpecialFeatureMappingViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<SpecialFeatureMappingViewModel> GetModel(IDataContext context,
                                                                      SpecialFeatureMappingFilter filter)
        {
            SpecialFeatureMappingViewModel model;

            if (filter.Action == SpecialFeatureMappingAction.Delete 
                || filter.Action == SpecialFeatureMappingAction.Mapping
                || filter.Action == SpecialFeatureMappingAction.Copy)
            {
                model = await GetFullAndPartialViewModelForFeatureMapping(context, filter);
            }
            else if (filter.Action == SpecialFeatureMappingAction.Mappings ||
                filter.Action == SpecialFeatureMappingAction.CopyAll)
            {
                model = await GetFullAndPartialViewModelForFeatureMappings(context, filter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, filter);
            }
            if (filter.Action != SpecialFeatureMappingAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(filter.Action.GetType(), filter.Action);
            }
            return model;
        }
        private static SpecialFeatureMappingViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                             SpecialFeatureMappingFilter filter)
        {
            var model = new SpecialFeatureMappingViewModel(GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<SpecialFeatureMappingViewModel> GetFullAndPartialViewModelForFeatureMapping
        (
            IDataContext context,
            SpecialFeatureMappingFilter filter
        )
        {
            var baseModel = GetBaseModel(context);
            var model = new SpecialFeatureMappingViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : int.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            var featureMapping = await context.Vehicle.GetFdpSpecialFeatureMapping(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = featureMapping.ProgrammeId,
                Gateway = featureMapping.Gateway,
                Code = model.SpecialFeatureMapping.Programme.VehicleName // In order to filter the gateways specific to the programme
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            model.Gateways = context.Vehicle.ListGateways(programmeFilter);

            // If we are copying to another gateway, we need to remove the source gateway from the list of available gateways
            if (filter.Action == SpecialFeatureMappingAction.Copy)
            {
                model.Gateways = model.Gateways.Where(g => !(g.Name.Equals(featureMapping.Gateway, StringComparison.InvariantCultureIgnoreCase)));
            }
            
            if (!(featureMapping is EmptyFdpSpecialFeatureMapping))
            {
                featureMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == featureMapping.ProgrammeId.GetValueOrDefault());
            }
            model.SpecialFeatureMapping = featureMapping;
           
            return model;
        }
        private static async Task<SpecialFeatureMappingViewModel> GetFullAndPartialViewModelForFeatureMappings
        (
            IDataContext context,
            SpecialFeatureMappingFilter filter
        )
        {
            var baseModel = GetBaseModel(context);
            var model = new SpecialFeatureMappingViewModel(baseModel)
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

            model.SpecialFeatureMappings = await context.Vehicle.ListFdpSpecialFeatureMappings(filter);
            model.TotalPages = model.SpecialFeatureMappings.TotalPages;
            model.TotalRecords = model.SpecialFeatureMappings.TotalRecords;
            model.TotalDisplayRecords = model.SpecialFeatureMappings.TotalDisplayRecords;

            foreach (var featureMapping in model.SpecialFeatureMappings.CurrentPage)
            {
                featureMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == featureMapping.ProgrammeId.GetValueOrDefault());
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(SpecialFeatureMappingViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(SpecialFeatureMappingViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            SpecialFeatureMapping = new EmptyFdpSpecialFeatureMapping();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = SpecialFeatureMappingAction.NotSet;
        }
    }
}

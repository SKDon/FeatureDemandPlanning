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
    public class FeatureViewModel : SharedModelBase
    {
        public FdpFeature Feature { get; set; }
        public PagedResults<FdpFeature> Features { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set; }

        public FeatureAction CurrentAction { get; set; }
    
        public FeatureViewModel() : base()
        {
            InitialiseMembers();
        }
        public FeatureViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<FeatureViewModel> GetModel(IDataContext context, FeatureFilter featureFilter)
        {
            FeatureViewModel model = null;

            if (featureFilter.Action == FeatureAction.Delete || featureFilter.Action == FeatureAction.Feature)
            {
                model = await GetFullAndPartialViewModelForFeature(context, featureFilter);
            }
            else if (featureFilter.Action == FeatureAction.Features)
            {
                model = await GetFullAndPartialViewModelForFeatures(context, featureFilter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, featureFilter);
            }
            if (featureFilter.Action != FeatureAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(featureFilter.Action.GetType(), featureFilter.Action);
            }
           
            return model;
        }
        private static FeatureViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                      FeatureFilter filter)
        {
            var model = new FeatureViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<FeatureViewModel> GetFullAndPartialViewModelForFeature(IDataContext context,
                                                                                               FeatureFilter filter)
        {
            var model = new FeatureViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings
            };
            var feature = await context.Vehicle.GetFdpFeature(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = feature.ProgrammeId,
                Gateway = feature.Gateway
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            
            if (!(feature is EmptyFdpFeature))
            {
                feature.Programme = model.Programmes.FirstOrDefault(p => p.Id == feature.ProgrammeId.GetValueOrDefault());
            }
            model.Feature = feature;
           
            return model;
        }
        private static async Task<FeatureViewModel> GetFullAndPartialViewModelForFeatures(IDataContext context,
                                                                                                FeatureFilter filter)
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new FeatureViewModel()
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

            model.Features = await context.Vehicle.ListFdpFeatures(filter);
            model.TotalPages = model.Features.TotalPages;
            model.TotalRecords = model.Features.TotalRecords;
            model.TotalDisplayRecords = model.Features.TotalDisplayRecords;

            foreach (var feature in model.Features.CurrentPage)
            {
                feature.Programme = model.Programmes.FirstOrDefault(p => p.Id == feature.ProgrammeId.GetValueOrDefault());
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(FeatureViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(FeatureViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            Feature = new EmptyFdpFeature();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = FeatureAction.NotSet;
        }

        
    }
}

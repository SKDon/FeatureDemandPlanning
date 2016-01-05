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
    public class TrimViewModel : SharedModelBase
    {
        public FdpTrim Trim { get; set; }
        public PagedResults<FdpTrim> Trims { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set; }

        public TrimAction CurrentAction { get; set; }
    
        public TrimViewModel() : base()
        {
            InitialiseMembers();
        }
        public TrimViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<TrimViewModel> GetModel(IDataContext context, TrimFilter trimFilter)
        {
            TrimViewModel model = null;

            if (trimFilter.Action == TrimAction.Delete || trimFilter.Action == TrimAction.Trim)
            {
                model = await GetFullAndPartialViewModelForTrim(context, trimFilter);
            }
            else if (trimFilter.Action == TrimAction.TrimLevels)
            {
                model = await GetFullAndPartialViewModelForTrims(context, trimFilter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, trimFilter);
            }
            if (trimFilter.Action != TrimAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(trimFilter.Action.GetType(), trimFilter.Action);
            }
           
            return model;
        }
        private static TrimViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                      TrimFilter filter)
        {
            var model = new TrimViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<TrimViewModel> GetFullAndPartialViewModelForTrim(IDataContext context,
                                                                                               TrimFilter filter)
        {
            var model = new TrimViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings
            };
            var trim = await context.Vehicle.GetFdpTrim(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = trim.ProgrammeId,
                Gateway = trim.Gateway
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            
            if (!(trim is EmptyFdpTrim))
            {
                trim.Programme = model.Programmes.FirstOrDefault(p => p.Id == trim.ProgrammeId);
            }
            model.Trim = trim;
           
            return model;
        }
        private static async Task<TrimViewModel> GetFullAndPartialViewModelForTrims(IDataContext context,
                                                                                                TrimFilter filter)
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new TrimViewModel()
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

            model.Trims = await context.Vehicle.ListFdpTrims(filter);
            model.TotalPages = model.Trims.TotalPages;
            model.TotalRecords = model.Trims.TotalRecords;
            model.TotalDisplayRecords = model.Trims.TotalDisplayRecords;

            foreach (var trim in model.Trims.CurrentPage)
            {
                trim.Programme = model.Programmes.FirstOrDefault(p => p.Id == trim.ProgrammeId);
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(TrimViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(TrimViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            Trim = new EmptyFdpTrim();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = TrimAction.NotSet;
        }

        
    }
}

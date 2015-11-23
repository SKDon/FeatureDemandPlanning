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
    public class IgnoredExceptionViewModel : SharedModelBase
    {
        public IgnoredExceptionAction CurrentAction { get; set; }
        public FdpImportErrorExclusion IgnoredException { get; set; }
        public PagedResults<FdpImportErrorExclusion> IgnoredExceptions { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<ModelBody> Bodies { get; set; }
        public IEnumerable<ModelEngine> Engines { get; set; }
        public IEnumerable<ModelTransmission> Transmissions { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set;}
       
        public IgnoredExceptionViewModel() : base()
        {
            InitialiseMembers();
        }
        public IgnoredExceptionViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<IgnoredExceptionViewModel> GetModel(IDataContext context,
                                                                      IgnoredExceptionFilter filter)
        {
            IgnoredExceptionViewModel model = null;

            if (filter.Action == IgnoredExceptionAction.Delete 
                || filter.Action == IgnoredExceptionAction.Exception)
            {
                model = await GetFullAndPartialViewModelForIgnoredException(context, filter);
            }
            else if (filter.Action == IgnoredExceptionAction.Exceptions)
            {
                model = await GetFullAndPartialViewModelForIgnoredExceptions(context, filter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, filter);
            }
            if (filter.Action != IgnoredExceptionAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(filter.Action.GetType(), filter.Action);
            }
            return model;
        }
        private static IgnoredExceptionViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                             IgnoredExceptionFilter filter)
        {
            var model = new IgnoredExceptionViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<IgnoredExceptionViewModel> GetFullAndPartialViewModelForIgnoredException
        (
            IDataContext context,
            IgnoredExceptionFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new IgnoredExceptionViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            var ignoredException = await context.Import.GetFdpImportErrorExclusion(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = ignoredException.ProgrammeId,
                Gateway = ignoredException.Gateway,
                Code = model.IgnoredException.Programme.VehicleName // In order to filter the gateways specific to the programme
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            model.Gateways = context.Vehicle.ListGateways(programmeFilter);
            
            if (!(ignoredException is EmptyFdpImportErrorExclusion))
            {
                ignoredException.Programme = model.Programmes.FirstOrDefault(p => p.Id == ignoredException.ProgrammeId.GetValueOrDefault());
            }
            model.IgnoredException = ignoredException;
           
            return model;
        }
        private static async Task<IgnoredExceptionViewModel> GetFullAndPartialViewModelForIgnoredExceptions
        (
            IDataContext context,
            IgnoredExceptionFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new IgnoredExceptionViewModel(baseModel)
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

            model.IgnoredExceptions = await context.Import.ListFdpIgnoredExceptions(filter);
            model.TotalPages = model.IgnoredExceptions.TotalPages;
            model.TotalRecords = model.IgnoredExceptions.TotalRecords;
            model.TotalDisplayRecords = model.IgnoredExceptions.TotalDisplayRecords;

            foreach (var ignoredException in model.IgnoredExceptions.CurrentPage)
            {
                ignoredException.Programme = model.Programmes.FirstOrDefault(p => p.Id == ignoredException.ProgrammeId.GetValueOrDefault());
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(IgnoredExceptionViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(IgnoredExceptionViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
        {
            model.Programmes = context.Vehicle.ListProgrammes(programmeFilter);
            model.Bodies = context.Vehicle.ListBodies(programmeFilter);
            model.Engines = context.Vehicle.ListEngines(programmeFilter);
            model.Transmissions = context.Vehicle.ListTransmissions(programmeFilter);
            model.Gateways = model.Programmes.ListGateways();
            model.CarLines = model.Programmes.ListCarLines();
            model.ModelYears = model.Programmes.ListModelYears();
        }
        private void InitialiseMembers()
        {
            IgnoredException = new EmptyFdpImportErrorExclusion();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Bodies = Enumerable.Empty<ModelBody>();
            Engines = Enumerable.Empty<ModelEngine>();
            Transmissions = Enumerable.Empty<ModelTransmission>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = IgnoredExceptionAction.NotSet;
        }
    }
}

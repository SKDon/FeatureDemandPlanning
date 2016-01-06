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
    public class DerivativeMappingViewModel : SharedModelBase
    {
        public DerivativeMappingAction CurrentAction { get; set; }
        public FdpDerivativeMapping DerivativeMapping { get; set; }
        public PagedResults<FdpDerivativeMapping> DerivativeMappings { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<ModelBody> Bodies { get; set; }
        public IEnumerable<ModelEngine> Engines { get; set; }
        public IEnumerable<ModelTransmission> Transmissions { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set;}
       
        public DerivativeMappingViewModel() : base()
        {
            InitialiseMembers();
        }
        public DerivativeMappingViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<DerivativeMappingViewModel> GetModel(IDataContext context,
                                                                      DerivativeMappingFilter filter)
        {
            DerivativeMappingViewModel model = null;

            if (filter.Action == DerivativeMappingAction.Delete 
                || filter.Action == DerivativeMappingAction.Mapping
                || filter.Action == DerivativeMappingAction.Copy)
            {
                model = await GetFullAndPartialViewModelForDerivativeMapping(context, filter);
            }
            else if (filter.Action == DerivativeMappingAction.Mappings ||
                filter.Action == DerivativeMappingAction.CopyAll)
            {
                model = await GetFullAndPartialViewModelForDerivativeMappings(context, filter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, filter);
            }
            if (filter.Action != DerivativeMappingAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(filter.Action.GetType(), filter.Action);
            }
            return model;
        }
        private static DerivativeMappingViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                             DerivativeMappingFilter filter)
        {
            var model = new DerivativeMappingViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<DerivativeMappingViewModel> GetFullAndPartialViewModelForDerivativeMapping
        (
            IDataContext context,
            DerivativeMappingFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new DerivativeMappingViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            var derivativeMapping = await context.Vehicle.GetFdpDerivativeMapping(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = derivativeMapping.ProgrammeId,
                Gateway = derivativeMapping.Gateway,
                Code = model.DerivativeMapping.Programme.VehicleName // In order to filter the gateways specific to the programme
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            model.Gateways = context.Vehicle.ListGateways(programmeFilter);

            // If we are copying to another gateway, we need to remove the source gateway from the list of available gateways
            if (filter.Action == DerivativeMappingAction.Copy)
            {
                model.Gateways = model.Gateways.Where(g => !(g.Name.Equals(derivativeMapping.Gateway, StringComparison.InvariantCultureIgnoreCase)));
            }
            
            if (!(derivativeMapping is EmptyFdpDerivativeMapping))
            {
                derivativeMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == derivativeMapping.ProgrammeId.GetValueOrDefault());
                derivativeMapping.Body = model.Bodies.FirstOrDefault(b => b.Id == derivativeMapping.BodyId);
                derivativeMapping.Engine = model.Engines.FirstOrDefault(e => e.Id == derivativeMapping.EngineId);
                derivativeMapping.Transmission = model.Transmissions.FirstOrDefault(t => t.Id == derivativeMapping.TransmissionId);
            }
            model.DerivativeMapping = derivativeMapping;
           
            return model;
        }
        private static async Task<DerivativeMappingViewModel> GetFullAndPartialViewModelForDerivativeMappings
        (
            IDataContext context,
            DerivativeMappingFilter filter
        )
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new DerivativeMappingViewModel(baseModel)
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

            model.DerivativeMappings = await context.Vehicle.ListFdpDerivativeMappings(filter);
            model.TotalPages = model.DerivativeMappings.TotalPages;
            model.TotalRecords = model.DerivativeMappings.TotalRecords;
            model.TotalDisplayRecords = model.DerivativeMappings.TotalDisplayRecords;

            foreach (var derivativeMapping in model.DerivativeMappings.CurrentPage)
            {
                derivativeMapping.Programme = model.Programmes.FirstOrDefault(p => p.Id == derivativeMapping.ProgrammeId.GetValueOrDefault());
                derivativeMapping.Body = model.Bodies.FirstOrDefault(b => b.Id == derivativeMapping.BodyId);
                derivativeMapping.Engine = model.Engines.FirstOrDefault(e => e.Id == derivativeMapping.EngineId);
                derivativeMapping.Transmission = model.Transmissions.FirstOrDefault(t => t.Id == derivativeMapping.TransmissionId);
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(DerivativeMappingViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(DerivativeMappingViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
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
            DerivativeMapping = new EmptyFdpDerivativeMapping();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Bodies = Enumerable.Empty<ModelBody>();
            Engines = Enumerable.Empty<ModelEngine>();
            Transmissions = Enumerable.Empty<ModelTransmission>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = DerivativeMappingAction.NotSet;
        }
    }
}

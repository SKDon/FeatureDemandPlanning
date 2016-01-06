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
    public class DerivativeViewModel : SharedModelBase
    {
        public FdpDerivative Derivative { get; set; }
        public PagedResults<FdpDerivative> Derivatives { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<ModelBody> Bodies { get; set; }
        public IEnumerable<ModelEngine> Engines { get; set; }
        public IEnumerable<ModelTransmission> Transmissions { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Gateway> Gateways { get; set; }
        public IEnumerable<ModelYear> ModelYears { get; set; }

        public DerivativeAction CurrentAction { get; set; }
    
        public DerivativeViewModel() : base()
        {
            InitialiseMembers();
        }
        public DerivativeViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<DerivativeViewModel> GetModel(IDataContext context, DerivativeFilter derivativeFilter)
        {
            DerivativeViewModel model = null;

            if (derivativeFilter.Action == DerivativeAction.Delete || derivativeFilter.Action == DerivativeAction.Derivative)
            {
                model = await GetFullAndPartialViewModelForDerivative(context, derivativeFilter);
            }
            else if (derivativeFilter.Action == DerivativeAction.Derivatives)
            {
                model = await GetFullAndPartialViewModelForDerivatives(context, derivativeFilter);
            }
            else
            {
                model = GetFullAndPartialViewModel(context, derivativeFilter);
            }
            if (derivativeFilter.Action != DerivativeAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(derivativeFilter.Action.GetType(), derivativeFilter.Action);
            }
           
            return model;
        }
        private static DerivativeViewModel GetFullAndPartialViewModel(IDataContext context,
                                                                      DerivativeFilter filter)
        {
            var model = new DerivativeViewModel(SharedModelBase.GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
            };
            HydrateModelWithCommonProperties(model, context);

            return model;
        }
        private static async Task<DerivativeViewModel> GetFullAndPartialViewModelForDerivative(IDataContext context,
                                                                                               DerivativeFilter filter)
        {
            var model = new DerivativeViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings
            };
            var derivative = await context.Vehicle.GetFdpDerivative(filter);
            var programmeFilter = new ProgrammeFilter()
            {
                ProgrammeId = derivative.ProgrammeId,
                Gateway = derivative.Gateway
            };
            HydrateModelWithCommonProperties(model, context, programmeFilter);
            
            if (!(derivative is EmptyFdpDerivative))
            {
                derivative.Programme = model.Programmes.FirstOrDefault(p => p.Id == derivative.ProgrammeId.GetValueOrDefault());
                derivative.Body = model.Bodies.FirstOrDefault(b => b.Id == derivative.BodyId);
                derivative.Engine = model.Engines.FirstOrDefault(e => e.Id == derivative.EngineId);
                derivative.Transmission = model.Transmissions.FirstOrDefault(t => t.Id == derivative.TransmissionId);
            }
            model.Derivative = derivative;
           
            return model;
        }
        private static async Task<DerivativeViewModel> GetFullAndPartialViewModelForDerivatives(IDataContext context,
                                                                                                DerivativeFilter filter)
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new DerivativeViewModel()
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

            model.Derivatives = await context.Vehicle.ListFdpDerivatives(filter);
            model.TotalPages = model.Derivatives.TotalPages;
            model.TotalRecords = model.Derivatives.TotalRecords;
            model.TotalDisplayRecords = model.Derivatives.TotalDisplayRecords;

            foreach (var derivative in model.Derivatives.CurrentPage)
            {
                derivative.Programme = model.Programmes.FirstOrDefault(p => p.Id == derivative.ProgrammeId.GetValueOrDefault());
                derivative.Body = model.Bodies.FirstOrDefault(b => b.Id == derivative.BodyId);
                derivative.Engine = model.Engines.FirstOrDefault(e => e.Id == derivative.EngineId);
                derivative.Transmission = model.Transmissions.FirstOrDefault(t => t.Id == derivative.TransmissionId);
            }

            return model;
        }
        private static void HydrateModelWithCommonProperties(DerivativeViewModel model, IDataContext context)
        {
            HydrateModelWithCommonProperties(model, context, new ProgrammeFilter());
        }
        private static void HydrateModelWithCommonProperties(DerivativeViewModel model, IDataContext context, ProgrammeFilter programmeFilter)
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
            Derivative = new EmptyFdpDerivative();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
            Bodies = Enumerable.Empty<ModelBody>();
            Engines = Enumerable.Empty<ModelEngine>();
            Transmissions = Enumerable.Empty<ModelTransmission>();
            Gateways = Enumerable.Empty<Gateway>();
            CarLines = Enumerable.Empty<CarLine>();
            ModelYears = Enumerable.Empty<ModelYear>();
            CurrentAction = DerivativeAction.NotSet;
        }

        
    }
}

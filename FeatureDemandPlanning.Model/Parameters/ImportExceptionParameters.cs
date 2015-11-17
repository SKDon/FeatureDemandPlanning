using FeatureDemandPlanning.Model;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class ImportExceptionParameters : ImportParameters
    {
        public int? ExceptionId { get; set; }
        public enums.ImportExceptionType ExceptionType { get; set; }

        public string ImportMarket { get; set; }
        public int? MarketId { get; set; }

        public string ImportFeatureCode { get; set; }
        public string FeatureCode { get; set; }
        public string FeatureDescription { get; set; }
        public int? FeatureGroupId { get; set; }

        public string ImportTrim { get; set; }
        public int? TrimId { get; set; }
        public string TrimName { get; set; }
        public string TrimAbbreviation { get; set; }
        public string TrimLevel { get; set; }
        public string DPCK { get; set; }

        public string ImportDerivativeCode { get; set; }
        public string DerivativeCode { get; set; }
        public int? BodyId { get; set; }
        public int? EngineId { get; set; }
        public int? TransmissionId { get; set; }

        public int? SpecialFeatureTypeId { get; set; }

        public ImportExceptionParameters() : base()
        {
            ExceptionType = enums.ImportExceptionType.NotSet;
            Action = enums.ImportAction.NotSet;
            FilterMessage = string.Empty;
        }
        public bool HasExceptionId()
        {
            return ExceptionId.HasValue;
        }
        public bool HasAction()
        {
            return Action != enums.ImportAction.NotSet;
        }
        public bool HasExceptionType()
        {
            return ExceptionType != enums.ImportExceptionType.NotSet;
        }
        public object GetActionSpecificParameters()
        {
            if (Action == enums.ImportAction.MapMissingFeature)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportFeatureCode = ImportFeatureCode,
                    FeatureCode = FeatureCode,
                    FeatureDescription = FeatureDescription
                };
            }

            if (Action == enums.ImportAction.AddMissingFeature)
            {
                return new
                {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportFeatureCode = ImportFeatureCode,
                    FeatureCode = FeatureCode,
                    FeatureDescription = FeatureDescription,
                    FeatureGroupId = FeatureGroupId
                };
            }

            if (Action == enums.ImportAction.MapMissingDerivative)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportDerivativeCode = ImportDerivativeCode,
                    DerivativeCode = DerivativeCode,
                    BodyId = BodyId,
                    EngineId = EngineId,
                    TransmissionId = TransmissionId
                };
            }
            if (Action == enums.ImportAction.AddMissingDerivative)
            {
                return new
                {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    DerivativeCode = ImportDerivativeCode,
                    BodyId = BodyId,
                    EngineId = EngineId,
                    TransmissionId = TransmissionId
                };
            }

            if (Action == enums.ImportAction.MapMissingMarket)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportMarket = ImportMarket,
                    MarketId = MarketId
                };
            }

            if (Action == enums.ImportAction.AddMissingTrim || Action == enums.ImportAction.MapMissingTrim) 
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportTrim = ImportTrim,
                    TrimId = TrimId,
                    TrimName = TrimName,
                    TrimAbbreviation = TrimAbbreviation,
                    TrimLevel = TrimLevel,
                    DPCK = DPCK
                };
            }

            if (Action == enums.ImportAction.AddSpecialFeature)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportFeatureCode = ImportFeatureCode,
                    SpecialFeatureTypeId = SpecialFeatureTypeId,
                };
            }

            if (Action == enums.ImportAction.IgnoreException)
            {
                return new
                {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    Gateway = Gateway,
                    ExceptionType = ExceptionType,
                    Action = Action
                };
            }

            return new { };
        }
    }
}
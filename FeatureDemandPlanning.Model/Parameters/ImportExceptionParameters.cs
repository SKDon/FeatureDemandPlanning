using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class ImportExceptionParameters : ImportParameters
    {
        public int? ExceptionId { get; set; }
        public ImportExceptionType ExceptionType { get; set; }
        public ImportExceptionAction Action { get; set; }
        public string FilterMessage { get; set; }

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
            ExceptionType = ImportExceptionType.NotSet;
            Action = ImportExceptionAction.NotSet;
            FilterMessage = string.Empty;
        }
        public bool HasExceptionId()
        {
            return ExceptionId.HasValue;
        }
        public bool HasAction()
        {
            return Action != ImportExceptionAction.NotSet;
        }
        public bool HasExceptionType()
        {
            return ExceptionType != ImportExceptionType.NotSet;
        }
        public object GetActionSpecificParameters()
        {
            if (Action == ImportExceptionAction.MapMissingFeature || Action == ImportExceptionAction.AddMissingFeature)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportFeatureCode = ImportFeatureCode,
                    FeatureCode = FeatureCode,
                    FeatureDescription = FeatureDescription,
                };
            }

            if (Action == ImportExceptionAction.MapMissingDerivative || Action == ImportExceptionAction.AddMissingDerivative)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportDerivativeCode = ImportDerivativeCode,
                    DerivativeCode = DerivativeCode,
                    BodyId = BodyId,
                    EngineId = EngineId,
                    TransmissionId = TransmissionId
                };
            }

            if (Action == ImportExceptionAction.MapMissingMarket)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportMarket = ImportMarket,
                    MarketId = MarketId
                };
            }

            if (Action == ImportExceptionAction.AddMissingTrim || Action == ImportExceptionAction.MapMissingTrim) 
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
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

            if (Action == ImportExceptionAction.AddSpecialFeature)
            {
                return new {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    ExceptionType = ExceptionType,
                    Action = Action,
                    ImportFeatureCode = ImportFeatureCode,
                    SpecialFeatureTypeId = SpecialFeatureTypeId,
                };
            }

            if (Action == ImportExceptionAction.IgnoreException)
            {
                return new
                {
                    ImportQueueId = ImportQueueId,
                    ExceptionId = ExceptionId,
                    ProgrammeId = ProgrammeId,
                    ExceptionType = ExceptionType,
                    Action = Action
                };
            }

            return new { };
        }
    }
}
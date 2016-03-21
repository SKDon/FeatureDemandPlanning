using System.Collections.Generic;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class ImportExceptionParameters : ImportParameters
    {
        public int? ExceptionId { get; set; }
        public IEnumerable<int> ExceptionIds { get; set; }  
        public enums.ImportExceptionType ExceptionType { get; set; }

        public string ImportMarket { get; set; }
        public int? MarketId { get; set; }

        public string ImportFeatureCode { get; set; }
        public string FeatureCode { get; set; }
        public string FeatureDescription { get; set; }
        public int? FeatureGroupId { get; set; }

        public string ImportTrim { get; set; }
        public int? TrimId { get; set; }
        public int? FdpTrimId { get; set; }
        public string TrimIdentifier { get; set; }
        public string TrimName { get; set; }
        public string TrimAbbreviation { get; set; }
        public string TrimLevel { get; set; }
        public string DPCK { get; set; }

        public string ImportDerivativeCode { get; set; }
        public string DerivativeCode { get; set; }
        public int? BodyId { get; set; }
        public int? EngineId { get; set; }
        public int? TransmissionId { get; set; }
        public IEnumerable<string> ImportDerivativeCodes { get; set; }
        public IEnumerable<string> ImportTrimLevels { get; set; }

        public int? SpecialFeatureTypeId { get; set; }
        public bool IsGlobalMapping { get; set; }

        public ImportExceptionParameters()
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
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action, ImportFeatureCode, FeatureCode, FeatureDescription
                };
            }

            if (Action == enums.ImportAction.AddMissingFeature)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action, ImportFeatureCode, FeatureCode, FeatureDescription, FeatureGroupId
                };
            }

            if (Action == enums.ImportAction.MapMissingDerivative)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action, ImportDerivativeCode, DerivativeCode, BodyId, EngineId, TransmissionId,
                    DocumentId
                };
            }
            if (Action == enums.ImportAction.MapOxoDerivative)
            {
                return new
                {
                    ExceptionId,
                    DerivativeCode,
                    DocumentId,
                    ProgrammeId,
                    Gateway
                };
            }
            if (Action == enums.ImportAction.MapOxoTrim)
            {
                return new
                {
                    ExceptionId,
                    TrimIdentifier,
                    DocumentId,
                    ProgrammeId,
                    Gateway
                };
            }
            if (Action == enums.ImportAction.AddMissingDerivative)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action,
                    DerivativeCode = ImportDerivativeCode, BodyId, EngineId, TransmissionId
                };
            }

            if (Action == enums.ImportAction.MapMissingMarket)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action, ImportMarket, MarketId, IsGlobalMapping
                };
            }

            if (Action == enums.ImportAction.AddMissingTrim || Action == enums.ImportAction.MapMissingTrim)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action, ImportTrim, TrimId, FdpTrimId, TrimName, TrimAbbreviation, TrimLevel, DPCK, DerivativeCode, TrimIdentifier
                };
            }

            if (Action == enums.ImportAction.AddSpecialFeature)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action, ImportFeatureCode, SpecialFeatureTypeId
                };
            }

            if (Action == enums.ImportAction.IgnoreException)
            {
                return new
                {
                    ImportQueueId, ExceptionId, ProgrammeId, Gateway, ExceptionType, Action
                };
            }

            if (Action == enums.ImportAction.IgnoreAll)
            {
                return new
                {
                    ExceptionIds,
                    Action
                };
            }

            return new {};
        }
    }
}
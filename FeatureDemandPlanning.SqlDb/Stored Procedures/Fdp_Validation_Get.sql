CREATE PROCEDURE [dbo].[Fdp_Validation_Get]
	  @FdpValidationId INT
AS

SET NOCOUNT ON;

SELECT
  FdpVolumeHeaderId
, FdpValidationId
, ValidationOn
, ValidationBy
, MarketId
, MarketGroupId
, ModelId
, FdpModelId
, ModelIdentifier
, FeatureId
, FdpFeatureId
, FeaturePackId
, ExclusiveFeatureGroup
, FeatureIdentifier
, BodyId
, EngineId
, TransmissionId
, [Message]
, FdpVolumeDataItemId
, FdpChangesetDataItemId
, FdpTakeRateSummaryId
, FdpTakeRateFeatureMixId
, FdpPowertrainDataItemId
FROM 
Fdp_Validation_VW 
WHERE 
FdpValidationId = @FdpValidationId;
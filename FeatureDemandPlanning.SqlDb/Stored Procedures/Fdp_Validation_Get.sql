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
, [Message]
, FdpVolumeDataItemId
, FdpChangesetDataItemId
, FdpTakeRateSummaryId
, FdpTakeRateFeatureMixId
FROM 
Fdp_Validation_VW 
WHERE 
FdpValidationId = @FdpValidationId;
CREATE PROCEDURE [dbo].[Fdp_Validation_Persist]
	  @FdpVolumeHeaderId		INT
	, @FdpValidationRuleId		INT
	, @MarketId					INT
	, @ModelId					INT = NULL
	, @FdpModelId				INT = NULL
	, @FeatureId				INT = NULL
	, @FdpFeatureId				INT = NULL
	, @FeaturePackId			INT = NULL
	, @ExclusiveFeatureGroup	NVARCHAR(200) = NULL
	, @FdpVolumeDataItemId		INT = NULL
	, @FdpTakeRateSummaryId		INT = NULL
	, @FdpTakeRateFeatureMixId	INT = NULL
	, @FdpChangesetDataItemId	INT = NULL
	, @Message					NVARCHAR(MAX)
	, @CDSId					NVARCHAR(16)
AS

SET NOCOUNT ON;

DECLARE @FdpValidationId INT;

INSERT INTO Fdp_Validation
(
	  FdpVolumeHeaderId
	, FdpValidationRuleId
	, ValidationBy
	, MarketId
	, ModelId	
	, FdpModelId
	, FeatureId	
	, FdpFeatureId
	, FeaturePackId
	, ExclusiveFeatureGroup	
	, FdpVolumeDataItemId
	, FdpTakeRateSummaryId
	, FdpTakeRateFeatureMixId
	, FdpChangesetDataItemId
	, [Message]
)
VALUES
(
	  @FdpVolumeHeaderId
	, @FdpValidationRuleId
	, @CDSId
	, @MarketId
	, @ModelId
	, @FdpModelId
	, @FeatureId
	, @FdpFeatureId
	, @FeaturePackId
	, @ExclusiveFeatureGroup
	, @FdpVolumeDataItemId
	, @FdpTakeRateSummaryId
	, @FdpTakeRateFeatureMixId
	, @FdpChangesetDataItemId
	, @Message
);

SET @FdpValidationId = SCOPE_IDENTITY();

EXEC Fdp_Validation_Get @FdpValidationId = @FdpValidationId
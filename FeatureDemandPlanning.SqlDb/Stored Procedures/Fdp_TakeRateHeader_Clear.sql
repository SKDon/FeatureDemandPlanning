CREATE PROCEDURE [dbo].[Fdp_TakeRateHeader_Clear]
	@FdpVolumeHeaderId	INT
AS
	SET NOCOUNT ON;
	
	-- Delete any validation errors
		
	DELETE FROM Fdp_Validation				WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Delete any changeset information
	
	DELETE FROM Fdp_ChangesetDataItem		WHERE FdpChangesetId IN 
	(
		SELECT FdpChangesetId FROM Fdp_Changeset WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	DELETE FROM Fdp_Changeset				WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Delete version information for the take rate file
	
	DELETE FROM Fdp_TakeRateVersion			WHERE FdpTakeRateHeaderId = @FdpVolumeHeaderId;
	
	-- Delete notes
	
	DELETE FROM Fdp_TakeRateDataItemNote	WHERE FdpTakeRateDataItemId IN 
	(
		SELECT FdpVolumeDataItemId FROM Fdp_VolumeDataItem WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	DELETE FROM Fdp_TakeRateDataItemNote	WHERE FdpTakeRateSummaryId IN 
	(
		SELECT FdpTakeRateSummaryId FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId
	)  
	
	-- Delete audit information

	DELETE FROM Fdp_TakeRateDataItemAudit	WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	DELETE FROM Fdp_TakeRateSummaryAudit	WHERE FdpTakeRateSummaryId IN 
	(
		SELECT FdpTakeRateSummaryId FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId
	)  
	DELETE FROM Fdp_TakeRateFeatureMixAudit WHERE FdpTakeRateFeatureMixId IN 
	(
		SELECT FdpTakeRateFeatureMixId FROM Fdp_TakeRateFeatureMix WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	--DELETE FROM Fdp_PowertrainDataItemAudit WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Delete take rate data
	
	DELETE FROM Fdp_VolumeDataItem			WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	DELETE FROM Fdp_TakeRateSummary			WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	DELETE FROM Fdp_TakeRateFeatureMix		WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	DELETE FROM Fdp_PowertrainDataItem		WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Delete the take rate record itself
	
	DELETE FROM Fdp_VolumeHeader			WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Delete any additional FDP trim levels, models and features
	
	DELETE FROM Fdp_DerivativeMapping
	WHERE
	FdpDerivativeMappingId IN 
	(
		SELECT FdpDerivativeMappingId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_DerivativeMapping	AS D	ON	H.ProgrammeId	= D.ProgrammeId
											AND H.Gateway		= D.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	
	DELETE FROM Fdp_TrimMapping
	WHERE
	FdpTrimMappingId IN 
	(
		SELECT FdpTrimMappingId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_TrimMapping		AS T	ON	H.ProgrammeId	= T.ProgrammeId
											AND H.Gateway		= T.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	
	DELETE FROM Fdp_FeatureMapping
	WHERE
	FdpFeatureMappingId IN 
	(
		SELECT FdpFeatureMappingId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_FeatureMapping		AS F	ON	H.ProgrammeId	= F.ProgrammeId
											AND H.Gateway		= F.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	
	DELETE FROM Fdp_Model
	WHERE
	FdpModelId IN 
	(
		SELECT FdpDerivativeId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_Model				AS M	ON	H.ProgrammeId	= M.ProgrammeId
											AND H.Gateway		= M.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	
	DELETE FROM Fdp_Derivative
	WHERE
	FdpDerivativeId IN 
	(
		SELECT FdpDerivativeId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_Derivative	AS D	ON	H.ProgrammeId	= D.ProgrammeId
									AND H.Gateway		= D.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	
	DELETE FROM Fdp_Trim
	WHERE
	FdpTrimId IN 
	(
		SELECT FdpTrimId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_Trim				AS T	ON	H.ProgrammeId	= T.ProgrammeId
											AND H.Gateway		= T.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
	
	DELETE FROM Fdp_Feature
	WHERE
	FdpFeatureId IN 
	(
		SELECT FdpFeatureId 
		FROM Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_Feature			AS F	ON	H.ProgrammeId	= F.ProgrammeId
											AND H.Gateway		= F.Gateway
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	)
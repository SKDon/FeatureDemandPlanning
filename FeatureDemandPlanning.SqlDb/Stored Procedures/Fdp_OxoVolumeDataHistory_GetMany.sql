CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataHistory_GetMany]
	@FdpOxoVolumeDataId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  AuditBy
		, AuditOn
		, Volume
		, PercentageTakeRate
	FROM
	(
		SELECT
			  ISNULL(CUR.UpdatedBy, CUR.CreatedBy) AS AuditBy
			, ISNULL(CUR.LastUpdated, CUR.CreatedOn) AS AuditOn
			, CUR.Volume
			, CUR.PercentageTakeRate
			
		FROM Fdp_OxoVolumeDataItem AS CUR
		WHERE
		CUR.FdpOxoVolumeDataItemId = @FdpOxoVolumeDataId
		
		UNION
		
		SELECT
			  AUDIT.AuditBy
			, AUDIT.AuditOn
			, AUDIT.Volume
			, AUDIT.PercentageTakeRate
			
		FROM Fdp_OxoVolumeDataItemAudit AS AUDIT
		WHERE
		AUDIT.FdpOxoVolumeDataItemId = @FdpOxoVolumeDataId
	)
	AS HISTORY
	ORDER BY
	HISTORY.AuditOn DESC
	
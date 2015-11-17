﻿CREATE PROCEDURE [dbo].[Fdp_ImportQueue_Get]
	@FdpImportQueueId	INT
AS
	SET NOCOUNT ON;
	
	IF @FdpImportQueueId IS NOT NULL 
		AND NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ImportQueue WHERE FdpImportQueueId = @FdpImportQueueId)
		RAISERROR (N'Import item does not exist', 16, 1);
		
	SELECT 
		  Q.FdpImportQueueId
		, I.FdpImportId
		, Q.CreatedOn
		, Q.CreatedBy
		, Q.FdpImportTypeId
		, Q.[Type]
		, Q.FdpImportStatusId
		, Q.[Status]
		, Q.OriginalFileName
		, Q.FilePath
		, Q.UpdatedOn
		, Q.Error
		, Q.ErrorOn
		, V.Id AS ProgrammeId
		, V.VehicleName
		, V.VehicleAKA
		, V.ModelYear
		, I.Gateway
		, CAST(CASE WHEN Q.ErrorOn IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasErrors
		
	FROM Fdp_ImportQueue_VW AS Q
	JOIN Fdp_Import			AS I	ON Q.FdpImportQueueId	= I.FdpImportQueueId
	JOIN OXO_Programme_VW	AS V	ON	I.ProgrammeId		= V.Id
	WHERE
	(@FdpImportQueueId IS NULL OR Q.FdpImportQueueId = @FdpImportQueueId);
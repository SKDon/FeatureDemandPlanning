CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_Delete]
	  @FdpImportErrorExclusionId	INT
	, @CDSId						NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_ImportErrorExclusion SET 
		  IsActive = 0,
		  UpdatedOn = GETDATE(),
		  UpdatedBy = @CDSId
	WHERE
	FdpImportErrorExclusionId = @FdpImportErrorExclusionId;

	-- Update any imports that have yet to complete processing and not cancelled re-enabling any of the same errors

	UPDATE E SET IsExcluded = 0
	FROM
	Fdp_ImportError					AS E
	JOIN Fdp_Import					AS I	ON	E.FdpImportQueueId			= I.FdpImportQueueId
	JOIN Fdp_ImportQueue			AS Q	ON	I.FdpImportQueueId			= Q.FdpImportQueueId
											AND Q.FdpImportStatusId IN (2, 4) -- Processing or error
	JOIN Fdp_ImportErrorExclusion	AS X	ON	I.ProgrammeId				= X.ProgrammeId
											AND I.Gateway					= X.Gateway
											AND E.ErrorMessage				= X.ErrorMessage
											AND X.FdpImportErrorExclusionId = @FdpImportErrorExclusionId;
	
	EXEC Fdp_ImportErrorExclusion_Get @FdpImportErrorExclusionId;
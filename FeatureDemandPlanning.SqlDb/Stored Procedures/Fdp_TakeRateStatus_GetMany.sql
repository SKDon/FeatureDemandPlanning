CREATE PROCEDURE [dbo].[Fdp_TakeRateStatus_GetMany]
AS
	SET NOCOUNT ON;
	
	SELECT 
		  S.FdpTakeRateStatusId AS StatusId
		, S.[Status]
		, S.[Description]
	FROM 
	Fdp_TakeRateStatus AS S
	WHERE
	S.IsActive = 1
	ORDER BY
	S.WorkflowStepId;
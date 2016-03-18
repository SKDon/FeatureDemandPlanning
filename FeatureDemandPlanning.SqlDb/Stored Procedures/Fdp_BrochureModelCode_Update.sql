CREATE PROCEDURE [dbo].[Fdp_BrochureModelCode_Update]
	  @DocumentId		AS INT
	, @BodyId			AS INT
	, @TransmissionId	AS INT
	, @EngineId			AS INT
	, @DerivativeCode	AS NVARCHAR(20) = NULL
	, @CDSID			AS NVARCHAR(16)
AS

	SET NOCOUNT ON;

	DECLARE @IsArchived AS BIT;
	DECLARE @OldBMC AS NVARCHAR(20);
	DECLARE @FdpImportId AS INT;
	
	SELECT TOP 1 @IsArchived = ISNULL(Archived, 0) FROM Oxo_Doc WHERE Id = @DocumentId;

	IF @IsArchived = 1
	BEGIN
		SELECT TOP 1 @OldBMC = BMC
		FROM
		OXO_Archived_Programme_Model
		WHERE
		Doc_Id = @DocumentId
		AND
		Body_Id = @BodyId
		AND
		Engine_Id = @EngineId
		AND
		Transmission_Id = @TransmissionId;

		UPDATE OXO_Archived_Programme_Model SET 
			BMC = @DerivativeCode,
			Updated_By = @CDSID,
			Last_Updated = GETDATE()
		WHERE
		Doc_Id = @DocumentId
		AND
		Body_Id = @BodyId
		AND
		Engine_Id = @EngineId
		AND
		Transmission_Id = @TransmissionId;

		SELECT
			  D.Id AS DocumentId
			, M.BMC AS DerivativeCode
			, M.Body_Id AS BodyId
			, M.Engine_Id AS EngineId
			, M.Transmission_Id AS TransmissionId
		FROM
		OXO_Doc AS D
		JOIN OXO_Archived_Programme_Model AS M ON D.Id = M.Doc_Id
		WHERE
		D.Id = @DocumentId
		AND
		Body_Id = @BodyId
		AND
		Engine_Id = @EngineId
		AND
		Transmission_Id = @TransmissionId;
	END
	ELSE
	BEGIN
		SELECT TOP 1 @OldBMC = BMC
		FROM
		OXO_Programme_Model
		WHERE
		Body_Id = @BodyId
		AND
		Engine_Id = @EngineId
		AND
		Transmission_Id = @TransmissionId;

		UPDATE M SET BMC = @DerivativeCode,
			Updated_By = @CDSID,
			Last_Updated = GETDATE()
		FROM
		OXO_Doc AS D
		JOIN OXO_Programme_Model AS M ON D.Programme_Id = M.Programme_Id
		WHERE
		D.Id = @DocumentId
		AND
		Body_Id = @BodyId
		AND
		Engine_Id = @EngineId
		AND
		Transmission_Id = @TransmissionId;

		SELECT
			  D.Id AS DocumentId
			, M.BMC AS DerivativeCode
			, M.Body_Id AS BodyId
			, M.Engine_Id AS EngineId
			, M.Transmission_Id AS TransmissionId
		FROM
		OXO_Doc AS D
		JOIN OXO_Programme_Model AS M ON D.Programme_Id = M.Programme_Id
		WHERE
		D.Id = @DocumentId
		AND
		Body_Id = @BodyId
		AND
		Engine_Id = @EngineId
		AND
		Transmission_Id = @TransmissionId;
	END

	IF ISNULL(@OldBMC, '') <> ''
	BEGIN
		UPDATE M SET DerivativeCode = @DerivativeCode
		FROM
		Fdp_DerivativeMapping AS M
		WHERE
		M.DocumentId = @DocumentId
	END
	
	-- If we have a worktray item for this document that is currently unprocessed and in an error state then 
	-- reprocess the derivative errors
	
	SELECT TOP 1 @FdpImportId = I.FdpImportId
	FROM
	Fdp_Import AS I
	JOIN Fdp_ImportQueue AS Q ON I.FdpImportQueueId = Q.FdpImportQueueId
	WHERE
	I.DocumentId = @DocumentId
	AND
	Q.FdpImportStatusId = 4
	
	IF @FdpImportId IS NOT NULL
	BEGIN
		EXEC Fdp_ImportData_Process @FdpImportId = @FdpImportId
	END;
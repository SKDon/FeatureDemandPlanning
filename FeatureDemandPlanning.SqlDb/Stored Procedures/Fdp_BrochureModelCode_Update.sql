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
	SELECT TOP 1 @IsArchived = ISNULL(Archived, 0) FROM Oxo_Doc WHERE Id = @DocumentId;

	IF @IsArchived = 1
	BEGIN
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
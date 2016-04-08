CREATE PROCEDURE [dbo].[Fdp_FeatureCode_Update]
	  @DocumentId		AS INT
	, @FeatureId		AS INT = NULL
	, @FeaturePackId	AS INT = NULL
	, @FeatureCode		AS NVARCHAR(20) = NULL
	, @CDSID			AS NVARCHAR(16)
AS

	SET NOCOUNT ON;

	DECLARE @IsArchived AS BIT;
	DECLARE @OldFeatureCode AS NVARCHAR(20);
	DECLARE @FdpImportId AS INT;
	
	SELECT TOP 1 @IsArchived = ISNULL(Archived, 0) FROM Oxo_Doc WHERE Id = @DocumentId;

	IF @FeaturePackId IS NOT NULL
	BEGIN
		SELECT TOP 1 @OldFeatureCode = Feat_Code
		FROM
		OXO_Feature_Ext
		WHERE
		ID = @FeatureId
		
		IF @IsArchived = 1
		BEGIN
			UPDATE OXO_Archived_Programme_Pack SET 
				Feature_Code = @FeatureCode,
				Updated_By = @CDSID,
				Last_Updated = GETDATE()
			WHERE
			Doc_Id = @DocumentId
			AND
			Id = @FeaturePackId

			SELECT
				  D.Id AS DocumentId
				, P.Feature_Code AS DerivativeCode
				, P.Id AS FeaturePackId
			FROM
			OXO_Doc AS D
			JOIN OXO_Archived_Programme_Pack AS P ON D.Id = P.Doc_Id
			WHERE
			D.Id = @DocumentId
			AND
			P.Id = @FeaturePackId
		END
		ELSE
		BEGIN
			UPDATE OXO_Programme_Pack SET 
				Feature_Code = @FeatureCode,
				Updated_By = @CDSID,
				Last_Updated = GETDATE()
			WHERE
			Id = @FeaturePackId

			SELECT
				  D.Id AS DocumentId
				, P.Feature_Code AS DerivativeCode
				, P.Id AS FeaturePackId
			FROM
			OXO_Doc AS D
			JOIN OXO_Programme_Pack AS P ON D.Programme_Id = P.Programme_Id
			WHERE
			P.Id = @FeaturePackId
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @OldFeatureCode = Feat_Code
		FROM
		OXO_Feature_Ext
		WHERE
		Id = @FeatureId;
		
		UPDATE F SET Feat_Code = @FeatureCode,
			Updated_By = @CDSID,
			Last_Updated = GETDATE()
		FROM
		OXO_Feature_Ext AS F
		WHERE
		Id = @FeatureId;

		SELECT
			  D.Id AS DocumentId
			, F.ID AS FeatureId
			, F.FeatureCode
		FROM
		OXO_Doc AS D
		JOIN OXO_Programme_Feature_VW AS F ON D.Programme_Id = F.ProgrammeId
		WHERE
		D.Id = @DocumentId
		AND
		F.ID = @FeatureId;
	END
	
	-- If we have a worktray item for this document that is currently unprocessed and in an error state then 
	-- reprocess the feature errors
	
	SELECT TOP 1 @FdpImportId = Q.FdpImportId
	FROM
	Fdp_ImportQueue_VW AS Q
	WHERE
	Q.DocumentId = @DocumentId
	AND
	Q.FdpImportStatusId = 4;
	
	IF @FdpImportId IS NOT NULL
	BEGIN
		EXEC Fdp_ImportData_Process @FdpImportId = @FdpImportId
	END;
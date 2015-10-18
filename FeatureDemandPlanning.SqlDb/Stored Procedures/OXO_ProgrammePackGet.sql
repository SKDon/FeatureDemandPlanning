CREATE PROCEDURE [OXO_ProgrammePackGet]
	@p_prog_Id INT,
	@p_doc_Id INT,
	@p_Id INT,
	@p_use_OA_code bit = 0

AS

	DECLARE @p_archived BIT;

	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;
	
	IF ISNULL(@p_archived,0) = 0
	BEGIN
		SELECT Id,
		       Programme_Id AS ProgrammeId,
		       Pack_Name AS Name,
		       Extra_Info AS ExtraInfo,
		       Rule_Text AS RuleText,
		       Feature_Code AS FeatureCode,
		       OA_Code AS OACode,
		       Created_By AS CreatedBy,
		       Created_On AS CreatedOn,
		       Updated_By AS UpdatedBy,
		       Last_Updated AS LastUpdated
		FROM OXO_Programme_Pack
		WHERE Id = @p_Id 
		AND Programme_Id = @p_prog_Id;	
	
	END
	ELSE
	BEGIN
		SELECT Id,
			   Doc_Id As DocId,
		       Programme_Id AS ProgrammeId,
		       Pack_Name AS Name,
		       Extra_Info AS ExtraInfo,
		       Rule_Text AS RuleText,
		       Feature_Code AS FeatureCode,
		       OA_Code AS OACode,
		       Created_By AS CreatedBy,
		       Created_On AS CreatedOn,
		       Updated_By AS UpdatedBy,
		       Last_Updated AS LastUpdated
		FROM OXO_Archived_Programme_Pack
		WHERE Id = @p_Id
		AND Doc_Id = @p_doc_Id
		AND Programme_Id = @p_prog_Id;	
	
	END
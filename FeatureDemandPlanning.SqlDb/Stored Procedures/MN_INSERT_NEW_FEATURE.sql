CREATE PROC [dbo].[MN_INSERT_NEW_FEATURE]
@p_Feat_Code         NVARCHAR(50),
@p_OA_Code           NVARCHAR(50),
@p_OXO_Grp           INT,
@p_EFG_Code          NVARCHAR(50),
@p_Description       NVARCHAR(500),
@p_Jag_Descr         NVARCHAR(500),
@p_LR_Descr          NVARCHAR(500),
@p_Veh_Avail         NVARCHAR(500)
AS
BEGIN

  DECLARE @_count INT;
  DECLARE @_feat_id INT;
  
  SELECT @_count = COUNT(*) 
  FROM OXO_IMP_Feature 
  WHERE Feat_Code = RTRIM(LTRIM(@p_Feat_Code));
  
  IF @_count = 0 
  BEGIN
  
	INSERT INTO OXO_IMP_Feature (Feat_Code, OA_Code, OXO_Grp, EFG_Code,
	                             Description, Status, Active, Created_By, Created_On)
	                     VALUES (@p_Feat_Code, @p_OA_Code, @p_OXO_Grp, @p_EFG_Code,
	                             @p_Description, 1, 1, 'system', GETDATE());
	
	SET @_feat_id = SCOPE_IDENTITY();

	INSERT INTO OXO_Feature_Ext (Id, Feat_Code, OA_Code, OXO_Grp, Feat_EFG,
	                             Description, Status, Active, Created_By, Created_On)
	                     VALUES (@_feat_id, @p_Feat_Code, @p_OA_Code, @p_OXO_Grp, @p_EFG_Code,
	                             @p_Description, 1, 1, 'system', GETDATE());
	
	IF @p_Jag_Descr IS NOT NULL	
	BEGIN
		EXEC MN_UPDATE_INSERT_Brand_DESC @p_Feat_Code, 'J', @p_Jag_Descr;
	END                             

	IF @p_LR_Descr IS NOT NULL	
	BEGIN
		EXEC MN_UPDATE_INSERT_Brand_DESC @p_Feat_Code, 'LR', @p_LR_Descr;
	END                             

	IF @p_Veh_Avail IS NOT NULL
	BEGIN
		
		DECLARE @tempStr NVARCHAR(2000);
		SET @tempStr = @p_Veh_Avail;

		WHILE LEN(@tempStr) > 0
		BEGIN
		  DECLARE @_veh NVARCHAR(50);
		  SET @_veh = LEFT(@tempStr, CHARINDEX(',', @tempStr+',')-1);
		  SET @_veh = RTRIM(LTRIM(@_veh));
		  EXEC MN_UPDATE_INSERT_VEH_AVAILABILITY @_veh, @_feat_id;
		  SET @tempStr = STUFF(@tempStr, 1, CHARINDEX(',', @tempStr+','), '')
		END
		
	END
	                          
  END
  
END
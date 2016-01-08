CREATE PROC MN_UPDATE_INSERT_Brand_DESC
@p_feat_Code NVARCHAR(50),
@p_Brand  NVARCHAR(50),
@p_Desc NVARCHAR(500)
AS
BEGIN

  UPDATE OXO_IMP_Brand_Desc 
  SET Brand_Desc = @p_Desc,
  Updated_By = 'SYSTEM',
  Last_Updated = GETDATE()
  WHERE Feat_Code = @p_feat_Code
  AND Brand = @p_Brand;
  
  IF @@ROWCOUNT = 0
  BEGIN
    INSERT INTO OXO_IMP_Brand_Desc (Feat_Code, Brand, Brand_Desc, Status, Created_By, Created_On)
	VALUES (@p_feat_Code, @p_Brand, @p_Desc, 1, 'SYSTEM', GETDATE());   
  END	

  UPDATE OXO_Feature_Brand_Desc 
  SET Brand_Desc = @p_Desc
  WHERE Feat_Code = @p_feat_Code
  AND Brand = CASE WHEN @p_Brand = 'J' THEN 'Jaguar' ELSE 'Land Rover' END;
  
  IF @@ROWCOUNT = 0
  BEGIN
    INSERT INTO OXO_Feature_Brand_Desc (Feat_Code, Brand, Brand_Desc)
	VALUES (@p_feat_Code, 
			CASE WHEN @p_Brand = 'J' THEN 'Jaguar' ELSE 'Land Rover' END,
			@p_Desc);   
  END	

END
CREATE PROCEDURE [dbo].[OXO_OXODoc_Bulk_Update] 
  @p_GUID nvarchar(500),
  @p_Doc_Id int,
  @p_Section nvarchar(50) = 'MBM',
  @p_Updated_By nvarchar(8)
AS
  
  DECLARE @_change_date DATETIME;  
  SET @_change_date = GETDATE();
     
  IF @p_section = 'MBM'
  BEGIN   
	  -- perform query - perform update first
	  UPDATE t1
	  SET T1.OXO_Code = T2.OXO_Code,
		  T1.Reminder = T2.Reminder,
		  T1.Updated_By = @p_Updated_By,
		  T1.Last_Updated = @_change_date
	  FROM dbo.OXO_Item_Data_MBM AS T1
	  INNER JOIN dbo.OXO_Temp_Working_Data AS T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id 
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Market_Group_Id = T2.Market_Group_Id
	  AND T1.Market_Id = T2.Market_Id
	  WHERE T2.GUID = @p_GUID
	  AND T2.OXO_Doc_Id = @p_Doc_Id
	  AND T2.Section = 'MBM';
	  
	  
	  -- perform query - perform insert
	  INSERT INTO dbo.OXO_Item_Data_MBM (OXO_Doc_Id, Model_Id, Market_Group_Id, Market_Id, OXO_Code, 
				Reminder, Created_By, Created_On, Updated_By, Last_Updated )
	  SELECT T1.OXO_Doc_Id, T1.Model_Id, T1.Market_Group_Id, T1.Market_Id, T1.OXO_Code, 
	            T1.Reminder, @p_Updated_By, @_change_date, @p_Updated_By, @_change_date
	  FROM dbo.OXO_Temp_Working_Data T1
	  LEFT OUTER JOIN dbo.OXO_Item_Data_MBM T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id  
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Market_Group_Id = T2.Market_Group_Id	  
	  AND T1.Market_Id = T2.Market_Id
	  WHERE T1.GUID = @p_GUID
	  AND T1.OXO_Doc_Id = @p_Doc_Id
	  AND T1.Section = 'MBM'
	  AND T2.ID IS NULL;
	 
	  -- Finally clear up the temp data
	  DELETE FROM dbo.OXO_Temp_Working_Data 
	  WHERE GUID = @p_GUID;
	  	  	  
  END
  
  IF @p_section = 'GSF'
  BEGIN   
	  -- perform query - perform update first
	  UPDATE t1
	  SET T1.OXO_Code = T2.OXO_Code,
		  T1.Reminder = T2.Reminder,
		  T1.Updated_By = @p_Updated_By,
		  T1.Last_Updated = @_change_date
	  FROM dbo.OXO_Item_Data_GSF AS T1
	  INNER JOIN dbo.OXO_Temp_Working_Data AS T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id 
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Feature_Id = T2.Feature_Id
	  WHERE T2.GUID = @p_GUID
	  AND T2.OXO_Doc_Id = @p_Doc_Id
	  AND T2.Section = 'GSF';
	  
	  -- perform query - perform insert
	  INSERT INTO dbo.OXO_Item_Data_GSF (OXO_Doc_Id, Model_Id, Feature_Id, OXO_Code, 
				Reminder, Created_By, Created_On, Updated_By, Last_Updated )
	  SELECT T1.OXO_Doc_Id, T1.Model_Id, T1.Feature_Id, T1.OXO_Code, 
	            T1.Reminder, @p_Updated_By, @_change_date, @p_Updated_By, @_change_date
	  FROM dbo.OXO_Temp_Working_Data T1
	  LEFT OUTER JOIN dbo.OXO_Item_Data_GSF T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id  
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Feature_Id = T2.Feature_Id
	  WHERE T1.GUID = @p_GUID
	  AND T1.OXO_Doc_Id = @p_Doc_Id
	  AND T1.Section = 'GSF'
	  AND T2.ID IS NULL;
	  
	  -- Finally clear up the temp data
	  DELETE FROM dbo.OXO_Temp_Working_Data 
	  WHERE GUID = @p_GUID;
	  
  END
  
  IF @p_section = 'FBM'
  BEGIN   
	  -- perform query - perform update first
	  UPDATE t1
	  SET T1.OXO_Code = T2.OXO_Code,
		  T1.Reminder = T2.Reminder,
		  T1.Updated_By = @p_Updated_By,
		  T1.Last_Updated = @_change_date
	  FROM dbo.OXO_Item_Data_FBM AS T1
	  INNER JOIN dbo.OXO_Temp_Working_Data AS T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id 
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Feature_Id = T2.Feature_Id
	  AND ISNULL(T1.Market_Id,0) = ISNULL(T2.Market_Id,0)
	  AND ISNULL(T1.Market_Group_Id,0) = ISNULL(T2.Market_Group_Id,0)
	  WHERE T2.GUID = @p_GUID
	  AND T2.OXO_Doc_Id = @p_Doc_Id
	  AND T2.Section = 'FBM';
	  
	  -- perform query - perform insert
	  INSERT INTO dbo.OXO_Item_Data_FBM (OXO_Doc_Id, Model_Id, Feature_Id, Market_Group_Id, Market_Id, OXO_Code, 
				Reminder, Created_By, Created_On, Updated_By, Last_Updated )
	  SELECT T1.OXO_Doc_Id, T1.Model_Id, T1.Feature_Id, T1.Market_Group_Id, T1.Market_Id, T1.OXO_Code, 
	            T1.Reminder, @p_Updated_By, @_change_date, @p_Updated_By, @_change_date
	  FROM dbo.OXO_Temp_Working_Data T1
	  LEFT OUTER JOIN dbo.OXO_Item_Data_FBM T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id  
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Feature_Id = T2.Feature_Id
	  AND ISNULL(T1.Market_Id,0) = ISNULL(T2.Market_Id,0)
	  AND ISNULL(T1.Market_Group_Id,0) = ISNULL(T2.Market_Group_Id,0)	  
	  WHERE T1.GUID = @p_GUID
	  AND T1.OXO_Doc_Id = @p_Doc_Id
	  AND T1.Section = 'FBM'
	  AND T2.ID IS NULL;
	  
	  DELETE FROM dbo.OXO_Temp_Working_Data 
	  WHERE GUID = @p_GUID
	  AND OXO_Doc_Id = @p_Doc_Id
	  AND Section = 'FBM';
	  
	  -- Do PCK
	  UPDATE t1
	  SET T1.OXO_Code = T2.OXO_Code,
		  T1.Reminder = T2.Reminder,
		  T1.Updated_By = @p_Updated_By,
		  T1.Last_Updated = @_change_date
	  FROM dbo.OXO_Item_Data_PCK AS T1
	  INNER JOIN dbo.OXO_Temp_Working_Data AS T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id 
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Pack_Id = T2.Pack_Id
	  AND ISNULL(T1.Market_Id,0) = ISNULL(T2.Market_Id,0)
	  AND ISNULL(T1.Market_Group_Id,0) = ISNULL(T2.Market_Group_Id,0)
	  WHERE T2.GUID = @p_GUID
	  AND T2.OXO_Doc_Id = @p_Doc_Id
	  AND T2.Section = 'PCK';
	  

	  -- perform query - perform insert
	  INSERT INTO dbo.OXO_Item_Data_PCK (OXO_Doc_Id, Model_Id, Pack_Id, Market_Group_Id, Market_Id, OXO_Code, 
				Reminder, Created_By, Created_On, Updated_By, Last_Updated )
	  SELECT T1.OXO_Doc_Id, T1.Model_Id, T1.Pack_Id, T1.Market_Group_Id, T1.Market_Id, T1.OXO_Code, 
	            T1.Reminder, @p_Updated_By, @_change_date, @p_Updated_By, @_change_date
	  FROM dbo.OXO_Temp_Working_Data T1
	  LEFT OUTER JOIN dbo.OXO_Item_Data_PCK T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id  
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Pack_Id = T2.Pack_Id
	  AND ISNULL(T1.Market_Id,0) = ISNULL(T2.Market_Id,0)
	  AND ISNULL(T1.Market_Group_Id,0) = ISNULL(T2.Market_Group_Id,0)	  
	  WHERE T1.GUID = @p_GUID
	  AND T1.OXO_Doc_Id = @p_Doc_Id
	  AND T1.Section = 'PCK'
	  AND T2.ID IS NULL;
	  
	  DELETE FROM dbo.OXO_Temp_Working_Data 
	  WHERE GUID = @p_GUID
	  AND OXO_Doc_Id = @p_Doc_Id
	  AND Section = 'PCK';
	  
	  -- Do FPS
	  UPDATE t1
	  SET T1.OXO_Code = T2.OXO_Code,
		  T1.Reminder = T2.Reminder,
		  T1.Updated_By = @p_Updated_By,
		  T1.Last_Updated = @_change_date
	  FROM dbo.OXO_Item_Data_FPS AS T1
	  INNER JOIN dbo.OXO_Temp_Working_Data AS T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id 
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Pack_Id = T2.Pack_Id
	  AND T1.Feature_Id = T2.Feature_Id
	  AND ISNULL(T1.Market_Id,0) = ISNULL(T2.Market_Id,0)
	  AND ISNULL(T1.Market_Group_Id,0) = ISNULL(T2.Market_Group_Id,0)
	  WHERE T2.GUID = @p_GUID
	  AND T2.OXO_Doc_Id = @p_Doc_Id
	  AND T2.Section = 'FPS';
	  

	  -- perform query - perform insert
	  INSERT INTO dbo.OXO_Item_Data_FPS (OXO_Doc_Id, Model_Id, Pack_Id, Feature_Id, Market_Group_Id, Market_Id, OXO_Code, 
				Reminder, Created_By, Created_On, Updated_By, Last_Updated )
	  SELECT T1.OXO_Doc_Id, T1.Model_Id, T1.Pack_Id, T1.Feature_Id, T1.Market_Group_Id, T1.Market_Id, T1.OXO_Code, 
	            T1.Reminder, @p_Updated_By, @_change_date, @p_Updated_By, @_change_date
	  FROM dbo.OXO_Temp_Working_Data T1
	  LEFT OUTER JOIN dbo.OXO_Item_Data_FPS T2
	  ON T1.OXO_Doc_Id = T2.OXO_Doc_Id  
	  AND T1.Model_Id = T2.Model_Id
	  AND T1.Pack_Id = T2.Pack_Id
	  AND T1.Feature_Id = T2.Feature_Id
	  AND ISNULL(T1.Market_Id,0) = ISNULL(T2.Market_Id,0)
	  AND ISNULL(T1.Market_Group_Id,0) = ISNULL(T2.Market_Group_Id,0)	  
	  WHERE T1.GUID = @p_GUID
	  AND T1.OXO_Doc_Id = @p_Doc_Id
	  AND T1.Section = 'FPS'
	  AND T2.ID IS NULL;
	  
	  DELETE FROM dbo.OXO_Temp_Working_Data 
	  WHERE GUID = @p_GUID
	  AND OXO_Doc_Id = @p_Doc_Id
	  AND Section = 'FPS';
	  
  END


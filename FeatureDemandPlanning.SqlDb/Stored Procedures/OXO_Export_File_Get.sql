CREATE PROCEDURE [OXO_Export_File_Get] 
  @p_guid nvarchar(50)
AS
	
	SELECT 
      F.Id  AS Id,      
      File_Size  AS FileSize,  
      File_Content  AS FileContent,  
      F.GUID AS GUID,
      ISNULL(R.OXODocName, 'Unknown') + '.xlsx' AS FileName
    FROM OXO_Export_File F
    LEFT OUTER JOIN OXO_Export_Request_VW R
    ON F.GUID = R.GUID
	WHERE F.GUID =  @p_guid;
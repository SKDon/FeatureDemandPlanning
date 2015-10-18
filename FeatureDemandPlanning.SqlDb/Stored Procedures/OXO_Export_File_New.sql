CREATE PROCEDURE [OXO_Export_File_New] 
   @p_GUID  nvarchar(50),
   @p_File_Content  image, 
   @p_File_Size  int,
   @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Export_File
  (
    GUID,
    File_Content,
    File_Size          
  )
  VALUES 
  (
    @p_GUID,
    @p_File_Content,
    @p_File_Size  
  );

  SET @p_Id = SCOPE_IDENTITY();
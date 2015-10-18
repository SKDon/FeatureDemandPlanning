

CREATE PROCEDURE [dbo].[OXO_Programme_File_New] 
   @p_Programme_Id  int,
   @p_File_Category  nvarchar(100), 
   @p_File_Comment  nvarchar(2000),    
   @p_File_Name  varchar(100), 
   @p_File_Ext  varchar(4), 
   @p_File_Type  varchar(20), 
   @p_File_Size  int, 
   @p_Gateway  nvarchar(100),
   @p_PACN  nvarchar(10),
   @p_File_Content  image, 
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Programme_File
  (
    Programme_Id,
    File_Category,
    File_Comment,
    File_Name,
    File_Ext,  
    File_Type,  
    File_Size,  
    Gateway,
    PACN,
    File_Content,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Programme_Id,
    @p_File_Category, 
    @p_File_Comment, 
    @p_File_Name,  
    @p_File_Ext,
    @p_File_Type,  
    @p_File_Size,  
    @p_Gateway,
    @p_PACN,
    @p_File_Content,  
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();


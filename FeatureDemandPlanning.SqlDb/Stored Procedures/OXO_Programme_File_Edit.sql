CREATE PROCEDURE [OXO_Programme_File_Edit] 
   @p_Id INT
  ,@p_File_Category  nvarchar(100) 
  ,@p_File_Comment  nvarchar(2000) 
  ,@p_File_Name  varchar(100)
  ,@p_File_Ext  varchar(4)  
  ,@p_File_Type  varchar(20) 
  ,@p_File_Size  int 
  ,@p_Gateway nvarchar(100)
  ,@p_PACN nvarchar(10)
  ,@p_GUID nvarchar(50)
  ,@p_File_Content  image   
  ,@p_Created_By  varchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  UPDATE dbo.OXO_Programme_File 
    SET 
  
  File_Category = @p_File_Category, 
  File_Comment = @p_File_Comment,    
  File_Name=@p_File_Name,
  File_Ext=@p_File_Ext,  
  File_Type=@p_File_Type,  
  File_Size=@p_File_Size,  
  Gateway = @p_Gateway,
  PACN = @p_PACN,
  GUID = @p_GUID,
  File_Content=@p_File_Content,  
  Created_By=@p_Created_By,  
  Created_On=@p_Created_On,  
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;


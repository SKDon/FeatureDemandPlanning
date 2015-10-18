
CREATE PROCEDURE [dbo].[OXO_Reference_List_Edit] 
   @p_Id INT
  ,@p_Code  nvarchar(50) 
  ,@p_Description  nvarchar(500) 
  ,@p_List_Name  nvarchar(100) 
  ,@p_Display_Order  int 
      
AS
	
  UPDATE dbo.OXO_Reference_List 
    SET 
  Code=@p_Code,  
  Description=@p_Description,  
  List_Name=@p_List_Name,  
  Display_Order=@p_Display_Order  
  	     
   WHERE Id = @p_Id;


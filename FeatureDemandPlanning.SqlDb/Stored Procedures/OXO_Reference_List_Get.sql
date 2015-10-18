
CREATE PROCEDURE [dbo].[OXO_Reference_List_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      Code  AS Code,  
      Description  AS Description,  
      List_Name  AS List_Name,  
      Display_Order  AS Display_Order  
      	     
    FROM dbo.OXO_Reference_List
	WHERE Id = @p_Id;




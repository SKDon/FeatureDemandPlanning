
CREATE  PROCEDURE [dbo].[OXO_Reference_List_New] 
   @p_Code  nvarchar(50), 
   @p_Description  nvarchar(500), 
   @p_List_Name  nvarchar(100), 
   @p_Display_Order  int, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Reference_List
  (
    Code,  
    Description,  
    List_Name,  
    Display_Order  
          
  )
  VALUES 
  (
    @p_Code,  
    @p_Description,  
    @p_List_Name,  
    @p_Display_Order  
      );

  SET @p_Id = SCOPE_IDENTITY();




CREATE PROCEDURE [dbo].[OXO_Reference_List_GetMany]
(
	@p_list_name VARCHAR(100)                 
)
AS
	
	   SELECT 
		Id  AS Id,
		Code  AS Code,  
		Description  AS Description,  
		List_Name  AS ListName,  
		Display_Order  AS DisplayOrder,  
		Active AS Active,
		Created_On AS CreatedOn,
		Created_By AS CreatedBy,
		Updated_By AS UpdatedBy,
		Last_Updated AS LastUpdated
		FROM dbo.OXO_Reference_List
		WHERE List_Name = ISNULL(@p_list_name, List_Name)
		ORDER By List_Name;
    


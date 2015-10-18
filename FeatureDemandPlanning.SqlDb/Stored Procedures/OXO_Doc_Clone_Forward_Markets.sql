CREATE PROCEDURE [dbo].[OXO_Doc_Clone_Forward_Markets] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_prog_id  int,    
   @p_clone_by nvarchar(50)
AS
BEGIN

	-- Get Market_Group
	INSERT INTO OXO_Programme_MarketGroup (Programme_Id, Group_Name, Extra_Info, Active, Display_Order, Clone_Id,
	                                       Created_By, Created_On, Updated_By, Last_Updated)
	SELECT Distinct @p_new_prog_id, Market_Group_Name, NULL, 1, Display_Order, Market_Group_Id,
	       @p_clone_by, GetDate(), @p_clone_by, GetDate()   
	FROM dbo.FN_Programme_Markets_Get (@p_prog_id, @p_doc_id);
	
	-- Get the Market_Link
	INSERT INTO OXO_Programme_MarketGroup_Market_Link (Programme_Id, Market_Group_Id, Country_Id, Sub_Region, CDSID)	                                       
	SELECT Distinct @p_new_prog_id, P.Id, M.Market_Id, M.SubRegion, @p_clone_by   
	FROM dbo.FN_Programme_Markets_Get (@p_prog_id, @p_doc_id) M
	INNER JOIN OXO_Programme_MarketGroup P
	ON P.Programme_Id = @p_new_prog_id
	AND P.Clone_Id = M.Market_Group_Id;
	
	

END


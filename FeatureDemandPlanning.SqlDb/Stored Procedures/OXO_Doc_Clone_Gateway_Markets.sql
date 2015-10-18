CREATE PROCEDURE [OXO_Doc_Clone_Gateway_Markets] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_doc_id  int,    
   @p_clone_by nvarchar(50)
AS
BEGIN

	DECLARE @p_archived BIT;

	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;

	IF (ISNULL(@p_archived, 0) = 0)
	BEGIN
  
		-- Get Market_Group
		INSERT INTO OXO_Archived_Programme_MarketGroup (Doc_Id, Programme_Id, Group_Name, Extra_Info, Active, Display_Order, Clone_Id,
											   Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Group_Name, Extra_Info, Active, Display_Order, Id,
			   @p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM OXO_Programme_MarketGroup
		WHERE Programme_Id = @p_prog_id;
		
		-- Get the Market_Link
		INSERT INTO OXO_Archived_Programme_MarketGroup_Market_Link (Doc_Id, Programme_Id, Market_Group_Id, Country_Id, Sub_Region, CDSID)	                                       
		SELECT Distinct @p_new_doc_id, @p_prog_id, P.Id, M.Country_Id, M.Sub_Region, @p_clone_by   
		FROM OXO_Programme_MarketGroup_Market_Link M
		INNER JOIN OXO_Archived_Programme_MarketGroup P
		ON P.Programme_Id = @p_prog_id
		AND P.Doc_Id = @p_new_doc_id
		AND P.Clone_Id = M.Market_Group_Id
		WHERE M.Programme_Id = @p_prog_id;
	END
	ELSE
	BEGIN
  
		-- Get Market_Group
		INSERT INTO OXO_Archived_Programme_MarketGroup (Doc_Id, Programme_Id, Group_Name, Extra_Info, Active, Display_Order, Clone_Id,
											   Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Group_Name, Extra_Info, Active, Display_Order, Id,
			   @p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM OXO_Archived_Programme_MarketGroup
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;		
		
		-- Get the Market_Link
		INSERT INTO OXO_Archived_Programme_MarketGroup_Market_Link (Doc_Id, Programme_Id, Market_Group_Id, Country_Id, Sub_Region, CDSID)	                                       
		SELECT Distinct @p_new_doc_id, @p_prog_id, P.Id, M.Country_Id, M.Sub_Region, @p_clone_by   
		FROM OXO_Archived_Programme_MarketGroup_Market_Link  M
		INNER JOIN OXO_Archived_Programme_MarketGroup P
		ON P.Programme_Id = @p_prog_id
		AND P.Doc_Id = @p_new_doc_id
		AND P.Clone_Id = M.Market_Group_Id
		WHERE M.Programme_Id = @p_prog_id
		AND M.Doc_Id = @p_doc_id;		
	END
	

END


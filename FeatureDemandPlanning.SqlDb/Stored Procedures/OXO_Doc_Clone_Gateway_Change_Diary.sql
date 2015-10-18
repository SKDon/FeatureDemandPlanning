CREATE PROCEDURE [dbo].[OXO_Doc_Clone_Gateway_Change_Diary] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_doc_id  int  
AS
BEGIN

	-- Get Market_Group
	INSERT INTO OXO_Change_Diary (
	OXO_Doc_Id, Programme_Id,
	Version_Info, Entry_Header, Entry_Date,
	Markets, Models, Features,
	Current_Fitment, Proposed_Fitment,
	Comment, PACN, ETracker, Order_Call,
	Build_Effective_Date,Requester,
	Pricing_Status, Digital_Status 
	)		
	SELECT @p_new_doc_id, @p_prog_id,
	Version_Info, Entry_Header, Entry_Date,
	Markets, Models, Features,
	Current_Fitment, Proposed_Fitment,
	Comment, PACN, ETracker, Order_Call,
	Build_Effective_Date, Requester,
	Pricing_Status, Digital_Status 	 
	FROM dbo.OXO_Change_Diary
	WHERE Programme_Id = @p_prog_id
	AND OXO_Doc_Id = @p_doc_id;
	


END


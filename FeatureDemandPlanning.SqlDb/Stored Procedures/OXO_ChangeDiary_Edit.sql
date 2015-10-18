CREATE PROCEDURE [OXO_ChangeDiary_Edit] 
   @p_Id INT
  ,@p_OXO_Doc_Id  int 
  ,@p_Programme_Id  int 
  ,@p_Version_Info  nvarchar(500)   
  ,@p_Entry_Header  nvarchar(max) 
  ,@p_Entry_Date  datetime 
  ,@p_Markets  nvarchar(max) 
  ,@p_Models  nvarchar(max) 
  ,@p_Features  nvarchar(max) 
  ,@p_Current_Fitment  nvarchar(50) 
  ,@p_Proposed_Fitment  nvarchar(50) 
  ,@p_Comment  nvarchar(max) 
  ,@p_Pricing_Status nvarchar(500)
  ,@p_Digital_Status nvarchar(500)
  ,@p_Requester nvarchar(100)
  ,@p_PACN  nvarchar(100) 
  ,@p_ETracker  nvarchar(100) 
  ,@p_Order_Call  nvarchar(100) 
  ,@p_Build_Effective_Date  datetime 
      
AS
	
  UPDATE dbo.OXO_Change_Diary 
    SET 
  OXO_Doc_Id=@p_OXO_Doc_Id,  
  Programme_Id=@p_Programme_Id,
  Version_Info=@p_Version_Info,      
  Entry_Header=@p_Entry_Header,  
  Entry_Date=@p_Entry_Date,  
  Markets=@p_Markets,  
  Models=@p_Models,  
  Features=@p_Features,  
  Current_Fitment=@p_Current_Fitment,  
  Proposed_Fitment=@p_Proposed_Fitment,  
  Comment=@p_Comment,
  Pricing_Status = @p_Pricing_Status,
  Digital_Status = @p_Digital_Status,    
  Requester = @p_Requester,
  PACN=@p_PACN,  
  ETracker=@p_ETracker,  
  Order_Call=@p_Order_Call,  
  Build_Effective_Date=@p_Build_Effective_Date  
  	     
   WHERE Id = @p_Id;


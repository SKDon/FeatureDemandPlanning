CREATE  PROCEDURE [OXO_ChangeDiary_New] 
   @p_OXO_Doc_Id  int, 
   @p_Programme_Id  int, 
   @p_Version_Info  nvarchar(500),    
   @p_Entry_Header  nvarchar(max), 
   @p_Entry_Date  datetime, 
   @p_Markets  nvarchar(max), 
   @p_Models  nvarchar(max), 
   @p_Features  nvarchar(max), 
   @p_Current_Fitment  nvarchar(50), 
   @p_Proposed_Fitment  nvarchar(50), 
   @p_Comment  nvarchar(max), 
   @p_Pricing_Status nvarchar(500),
   @p_Digital_Status nvarchar(500),
   @p_Requester nvarchar(100),
   @p_PACN  nvarchar(100), 
   @p_ETracker  nvarchar(100), 
   @p_Order_Call  nvarchar(100), 
   @p_Build_Effective_Date  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Change_Diary
  (
    OXO_Doc_Id,  
    Programme_Id,  
    Version_Info,
    Entry_Header,  
    Entry_Date,  
    Markets,  
    Models,  
    Features,  
    Current_Fitment,  
    Proposed_Fitment,  
    Comment,  
    Pricing_Status,
    Digital_Status,   
    Requester,
    PACN,  
    ETracker,  
    Order_Call,  
    Build_Effective_Date  
          
  )
  VALUES 
  (
    @p_OXO_Doc_Id,  
    @p_Programme_Id,
    @p_Version_Info,  
    @p_Entry_Header,  
    @p_Entry_Date,  
    @p_Markets,  
    @p_Models,  
    @p_Features,  
    @p_Current_Fitment,  
    @p_Proposed_Fitment,  
    @p_Comment, 
    @p_Pricing_Status,
    @p_Digital_Status,    
    @p_Requester,
    @p_PACN,  
    @p_ETracker,  
    @p_Order_Call,  
    @p_Build_Effective_Date  
      );

  SET @p_Id = SCOPE_IDENTITY();


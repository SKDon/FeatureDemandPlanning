CREATE PROCEDURE [dbo].[OXO_ChangeDiary_GetMany]
	@p_OXO_Doc_Id INT	 
AS
	
   SELECT 
    Id  AS Id,
    OXO_Doc_Id  AS OXODocId,  
    Programme_Id  AS ProgrammeId,
    Version_Info AS VersionInfo,   
    Entry_Header  AS EntryHeader,  
    Entry_Date  AS EntryDate,  
    Markets  AS Markets,  
    Models  AS Models,  
    Features  AS Features,  
    Current_Fitment  AS CurrentFitment,  
    Proposed_Fitment  AS ProposedFitment,  
    Comment  AS Comment,  
    Pricing_Status AS PricingStatus,
    Digital_Status AS DigitalStatus,
    Requester AS Requester,
    PACN  AS PACN,  
    ETracker  AS ETracker,  
    Order_Call  AS OrderCall,  
    Build_Effective_Date  AS BuildEffectiveDate  
    FROM dbo.OXO_Change_Diary
    WHERE OXO_Doc_Id = @p_OXO_Doc_Id
    ORDER BY  Entry_Date DESC, Version_Info
    ;


CREATE VIEW [dbo].[OXO_Item_Data_Hist_VW]
AS


  SELECT H.Set_Id, D.Section, D.OXO_Doc_Id, D.Model_Id, D.Market_Id, 
         D.Market_Group_Id,  D.Feature_Id, H.Item_Id, H.Item_Code,  
         S.Reminder AS Reminder, S.Version_Id AS VersionId,
         S.Updated_By, S.Last_Updated
    FROM dbo.OXO_Item_Data_VW D 
    INNER JOIN dbo.OXO_Item_Data_Hist H     
    ON D.Id = H.Item_Id
    AND D.Section = H.Section
    INNER JOIN dbo.OXO_Change_Set S
    ON H.Set_Id = S.Set_Id

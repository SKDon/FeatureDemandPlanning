CREATE VIEW [dbo].[OXO_Programme_File_VW]
AS
SELECT     F.Id, 
           F.Programme_Id, 
           F.File_Category,
           F.File_Comment,
           F.File_Name, 
           F.File_Ext, 
           ISNULL(R.Description, 'Unknown File Type') AS File_Desc, 
           F.File_Type, 
           ISNULL(E.File_Size, F.File_Size) AS File_Size, 
           ISNULL(E.File_Content, F.File_Content) AS File_Content, 
           F.Created_By, 
           F.Created_On, 
           F.Updated_By, 
           F.Last_Updated,
           F.Gateway,
           F.PACN,
           F.GUID,
           CASE WHEN Q.GUID IS NULL THEN 'Done'
                WHEN Q.Status IN ('New_Request', 'Process_Start') THEN 'Queued'
                WHEN Q.Status = 'Process_End' THEN 'Done'
                ELSE Q.Status
           END AS Status
FROM       dbo.OXO_Programme_File  F
		   LEFT OUTER JOIN dbo.OXO_Reference_List R
           ON F.File_Ext = R.Code
           AND R.List_Name = 'DocumentType'
           LEFT OUTER JOIN dbo.OXO_Export_File E
           ON E.GUID = F.GUID
		   LEFT OUTER JOIN dbo.OXO_Export_Queue Q
           ON Q.GUID = F.GUID


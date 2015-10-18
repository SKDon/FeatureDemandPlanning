

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
           F.File_Size, 
           F.File_Content, 
           F.Created_By, 
           F.Created_On, 
           F.Updated_By, 
           F.Last_Updated,
           F.Gateway,
           F.PACN
FROM       dbo.OXO_Programme_File  F
		   LEFT OUTER JOIN dbo.OXO_Reference_List R
           ON F.File_Ext = R.Code
           AND R.List_Name = 'DocumentType'


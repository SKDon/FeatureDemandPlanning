CREATE TABLE [dbo].[OXO_Item_Data_MBM] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Section]         NVARCHAR (50)  CONSTRAINT [DF_OXO_Item_Data_MBM_Section] DEFAULT (N'MBM') NOT NULL,
    [OXO_Doc_Id]      INT            NOT NULL,
    [Model_Id]        INT            NOT NULL,
    [Market_Group_Id] INT            NULL,
    [Market_Id]       INT            NOT NULL,
    [OXO_Code]        NVARCHAR (50)  NULL,
    [Reminder]        NVARCHAR (MAX) NULL,
    [Active]          BIT            CONSTRAINT [DF_OXO_Item_Data_MBM_Active] DEFAULT ((1)) NULL,
    [Created_By]      NVARCHAR (8)   NULL,
    [Created_On]      DATETIME       NULL,
    [Updated_By]      NVARCHAR (8)   NULL,
    [Last_Updated]    DATETIME       NULL,
    CONSTRAINT [PK_OXO_Item_Data_MBM] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [Idx_Doc_Id]
    ON [dbo].[OXO_Item_Data_MBM]([OXO_Doc_Id] ASC, [Active] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Market_Id]
    ON [dbo].[OXO_Item_Data_MBM]([Market_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_MarketGroup_Id]
    ON [dbo].[OXO_Item_Data_MBM]([Market_Group_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Model_Id]
    ON [dbo].[OXO_Item_Data_MBM]([Model_Id] ASC);


GO
CREATE TRIGGER [Tri_Item_Data_MBM_Hist_Insert]
ON [OXO_Item_Data_MBM]
FOR INSERT
/* Fire this trigger when a row is INSERTED */

AS BEGIN

  SET NOCOUNT ON;
       
  INSERT INTO OXO_Change_Set (OXO_Doc_Id, Section, Reminder, Version_Id, Version_Label, Updated_By, Last_Updated)
  (
    SELECT DISTINCT I.OXO_Doc_Id, I.Section, I.Reminder, O.Version_Id, 
    dbo.OXO_Version_Label_Get(O.Version_Id, O.Status),
    I.Updated_By, GETDATE() 
    FROM INSERTED I
    INNER JOIN OXO_Doc O
    ON I.OXO_Doc_Id = O.Id   
   );
  
  INSERT INTO dbo.OXO_Item_Data_Hist 
              (Item_Id, Section, Item_Code, Prev_Code, Set_Id) 
  SELECT I.Id, I.Section, I.OXO_Code, NULL, MAX(C.Set_Id)
  FROM INSERTED I
  INNER JOIN  OXO_Change_Set C
  ON I.OXO_Doc_Id = C.OXO_Doc_Id  
  AND I.Section = C.Section
  GROUP BY I.Id, I.Section, I.OXO_Code ;
  
END

GO
CREATE TRIGGER [Tri_Item_Data_MBM_Hist_Update]
ON [OXO_Item_Data_MBM]
FOR UPDATE
/* Fire this trigger when a row is INSERTED */

AS BEGIN

  SET NOCOUNT ON;
       
  INSERT INTO OXO_Change_Set (OXO_Doc_Id, Section, Reminder, Version_Id, Version_Label, Updated_By, Last_Updated)
  (
	   SELECT DISTINCT I.OXO_DOc_Id, I.Section, I.Reminder, O.Version_Id, 
	   dbo.OXO_Version_Label_Get(O.Version_Id, O.Status),
	   I.Updated_By, GETDATE() 
	   FROM INSERTED I 
	   INNER JOIN DELETED D 
	   ON I.ID = D.ID 	   
	   AND ISNULL(I.OXO_CODE, '') != ISNULL(D.OXO_CODE, '')
	   INNER JOIN OXO_DOC O
	   ON I.OXO_Doc_Id = O.Id
   );
  -- providing this is not changing the OXO_doc_id 
  
  INSERT INTO dbo.OXO_Item_Data_Hist (Item_Id, Section, Item_Code, Prev_Code, Set_Id) 
  SELECT I.Id, I.Section, I.OXO_Code, D.OXO_Code, MAX(C.Set_Id)
  FROM INSERTED I
  INNER JOIN DELETED D
  ON I.Id = D.Id
  AND ISNULL(I.OXO_CODE, '') != ISNULL(D.OXO_CODE, '')
  LEFT OUTER JOIN  OXO_Change_Set C
  ON I.OXO_Doc_Id = C.OXO_Doc_Id  
  AND I.Section = C.Section
  GROUP BY I.Id, I.Section, I.OXO_Code, D.OXO_Code;
  
END

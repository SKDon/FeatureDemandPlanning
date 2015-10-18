CREATE TABLE [dbo].[OXO_Item_Data] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Section]            NVARCHAR (50)   NOT NULL,
    [Model_Id]           INT             NOT NULL,
    [Market_Group_Id]    INT             NULL,
    [Market_Id]          INT             NULL,
    [Feature_Id]         INT             NULL,
    [OXO_Doc_Id]         INT             NULL,
    [OXO_Code]           NVARCHAR (50)   NULL,
    [Take_Rate]          DECIMAL (18, 2) NULL,
    [Historic_Take_Rate] DECIMAL (18, 2) NULL,
    [Active]             BIT             CONSTRAINT [DF_OXO_Item_Data_Active] DEFAULT ((1)) NULL,
    [Created_By]         NVARCHAR (8)    NULL,
    [Created_On]         DATETIME        NULL,
    [Updated_By]         NVARCHAR (8)    NULL,
    [Last_Updated]       DATETIME        NULL,
    [Pack_Id]            INT             NULL,
    [Reminder]           NVARCHAR (500)  NULL,
    CONSTRAINT [PK_OXO_Item_Data] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Item_Data_OXO_Doc] FOREIGN KEY ([OXO_Doc_Id]) REFERENCES [dbo].[OXO_Doc] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Model_Id]
    ON [dbo].[OXO_Item_Data]([Model_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Market_Id]
    ON [dbo].[OXO_Item_Data]([Market_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Feature_Id]
    ON [dbo].[OXO_Item_Data]([Feature_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Doc_Id]
    ON [dbo].[OXO_Item_Data]([OXO_Doc_Id] ASC, [Section] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Market_Group_Id]
    ON [dbo].[OXO_Item_Data]([Market_Group_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Pack_Id]
    ON [dbo].[OXO_Item_Data]([Pack_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Item_Data]
    ON [dbo].[OXO_Item_Data]([Section] ASC, [OXO_Doc_Id] ASC, [Active] ASC)
    INCLUDE([Model_Id], [Market_Id], [OXO_Code]);


GO
CREATE TRIGGER [Tri_Item_Data_Hist_Insert]
ON [OXO_Item_Data]
FOR INSERT
/* Fire this trigger when a row is INSERTED */

AS BEGIN

  SET NOCOUNT ON;
       
  INSERT INTO OXO_Change_Set (OXO_Doc_Id, Section, Reminder, Version_Id, Updated_By, Last_Updated)
  (
    SELECT DISTINCT I.OXO_Doc_Id, I.Section, I.Reminder, O.Version_Id, I.Updated_By, GETDATE() 
    FROM INSERTED I
    INNER JOIN OXO_Doc O
    ON I.OXO_Doc_Id = O.Id   
   );
  
  INSERT INTO dbo.OXO_Item_Data_Hist 
              (Item_Id, Item_Code, Prev_Code, Set_Id) 
  SELECT I.Id, I.OXO_Code, NULL, MAX(C.Set_Id)
  FROM INSERTED I
  INNER JOIN  OXO_Change_Set C
  ON I.OXO_Doc_Id = C.OXO_Doc_Id  
  AND I.Section = C.Section
  GROUP BY I.Id, I.OXO_Code;
  
END

GO
CREATE TRIGGER [Tri_Item_Data_Hist_Update]
ON [OXO_Item_Data]
FOR UPDATE
/* Fire this trigger when a row is INSERTED */

AS BEGIN

  SET NOCOUNT ON;
       
  INSERT INTO OXO_Change_Set (OXO_Doc_Id, Section, Reminder, Version_Id, Updated_By, Last_Updated)
  (
	   SELECT DISTINCT I.OXO_DOc_Id, I.Section, I.Reminder, O.Version_Id, I.Updated_By, GETDATE() 
	   FROM INSERTED I 
	   INNER JOIN DELETED D 
	   ON I.ID = D.ID 	   
	   AND ISNULL(I.OXO_CODE, '') != ISNULL(D.OXO_CODE, '')
	   INNER JOIN OXO_DOC O
	   ON I.OXO_Doc_Id = O.Id
   );
  -- providing this is not changing the OXO_doc_id 
  
  INSERT INTO dbo.OXO_Item_Data_Hist (Item_Id, Item_Code, Prev_Code, Set_Id) 
  SELECT I.Id, I.OXO_Code, D.OXO_Code, MAX(C.Set_Id)
  FROM INSERTED I
  INNER JOIN DELETED D
  ON I.Id = D.Id
  AND ISNULL(I.OXO_CODE, '') != ISNULL(D.OXO_CODE, '')
  LEFT OUTER JOIN  OXO_Change_Set C
  ON I.OXO_Doc_Id = C.OXO_Doc_Id  
  AND I.Section = C.Section
  GROUP BY I.Id, I.OXO_Code, D.OXO_Code;
  
END

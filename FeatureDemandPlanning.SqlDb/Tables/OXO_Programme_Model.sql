CREATE TABLE [dbo].[OXO_Programme_Model] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [Programme_Id]    INT           NOT NULL,
    [Body_Id]         INT           NOT NULL,
    [Engine_Id]       INT           NOT NULL,
    [Transmission_Id] INT           NOT NULL,
    [Trim_Id]         INT           NOT NULL,
    [Active]          BIT           NULL,
    [Created_By]      NVARCHAR (8)  NULL,
    [Created_On]      DATETIME      NULL,
    [Updated_By]      NVARCHAR (8)  NULL,
    [Last_Updated]    DATETIME      NULL,
    [BMC]             NVARCHAR (10) NULL,
    [CoA]             NVARCHAR (10) NULL,
    [KD]              BIT           NULL,
    [Clone_Id]        INT           NULL,
    [ChangeSet_Id]    INT           NULL,
    CONSTRAINT [PK_OXO_Programme_Variant] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Variant_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Variant_OXO_Programme_Body] FOREIGN KEY ([Body_Id]) REFERENCES [dbo].[OXO_Programme_Body] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Variant_OXO_Programme_Engine] FOREIGN KEY ([Engine_Id]) REFERENCES [dbo].[OXO_Programme_Engine] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Variant_OXO_Programme_Transmission] FOREIGN KEY ([Transmission_Id]) REFERENCES [dbo].[OXO_Programme_Transmission] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Variant_OXO_Programme_Trim] FOREIGN KEY ([Trim_Id]) REFERENCES [dbo].[OXO_Programme_Trim] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Idx_Prog_Model]
    ON [dbo].[OXO_Programme_Model]([Programme_Id] ASC, [Active] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_Programme_Model_CoA]
    ON [dbo].[OXO_Programme_Model]([CoA] ASC);


GO
CREATE TRIGGER [dbo].[Tri_Programme_Model]
ON [dbo].[OXO_Programme_Model]
FOR INSERT, UPDATE, DELETE 
/* Fire this trigger when a row is INSERTed or UPDATEd */
AS BEGIN

   SET NOCOUNT ON;
       	
   IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Add Programme Model', Programme_Id, 'Programme', 
		       Id, 'Model',	  
		       null, null, Created_By, GETDATE(), Changeset_Id
		FROM INSERTED;			
	END

   IF EXISTS(SELECT * FROM DELETED) AND EXISTS (SELECT * FROM INSERTED)
     BEGIN
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT CASE WHEN I.Active = 1 THEN 'Add Programme Model'
		       ELSE 'Remove Programme Model' END,
		       I.Programme_Id, 'Programme', I.ID, 'Model', null, null, I.Updated_By, GETDATE(), I.Changeset_Id 		      		
		FROM INSERTED I
		INNER JOIN DELETED D
		ON I.Id = D.Id
		AND I.Active != D.Active;
     END	


   IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN 
		INSERT INTO OXO_Event_Log(Event_Type, Event_Parent_Id, Event_Parent_Object, 
		                          Event_Parent2_Id, Event_Parent2_Object,
		                          Event_Parent3_Id, Event_Parent3_Object,
		                          Event_CDSID, Event_DateTime, Changeset_Id) 
		SELECT 'Remove Programme Model', Programme_Id, 'Programme', 
		       Id, 'Model',	
		       null, null, Updated_By, GETDATE(), Changeset_Id
		FROM DELETED;							
	END

END

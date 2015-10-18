CREATE TABLE [dbo].[OXO_Programme_Rule_Result] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [OXO_Doc_Id]   INT            NOT NULL,
    [Programme_Id] INT            NOT NULL,
    [Object_Level] NVARCHAR (3)   NOT NULL,
    [Object_Id]    INT            NOT NULL,
    [Rule_Id]      INT            NOT NULL,
    [Model_Id]     INT            NOT NULL,
    [Rule_Result]  BIT            NOT NULL,
    [Created_By]   NVARCHAR (8)   NOT NULL,
    [Created_On]   DATETIME       NOT NULL,
    [Result_Info]  NVARCHAR (500) NULL,
    CONSTRAINT [PK_OXO_Programme_Rule_Result] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_Rule_Result_OXO_Doc] FOREIGN KEY ([OXO_Doc_Id]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Rule_Result_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Rule_Result_OXO_Programme_Model] FOREIGN KEY ([Model_Id]) REFERENCES [dbo].[OXO_Programme_Model] ([Id]),
    CONSTRAINT [FK_OXO_Programme_Rule_Result_OXO_Programme_Rule] FOREIGN KEY ([Rule_Id]) REFERENCES [dbo].[OXO_Programme_Rule] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_OXO_Programme_Rule_Result_OXO_Doc_Id]
    ON [dbo].[OXO_Programme_Rule_Result]([OXO_Doc_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OXO_Programme_Rule_Result_Programme_Id]
    ON [dbo].[OXO_Programme_Rule_Result]([Programme_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OXO_Programme_Rule_Result_Model_Id]
    ON [dbo].[OXO_Programme_Rule_Result]([Model_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OXO_Programme_Rule_Result_Rule_Id]
    ON [dbo].[OXO_Programme_Rule_Result]([Rule_Id] ASC);


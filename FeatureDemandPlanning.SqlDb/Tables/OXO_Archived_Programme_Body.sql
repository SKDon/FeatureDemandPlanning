CREATE TABLE [dbo].[OXO_Archived_Programme_Body] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Doc_Id]       INT           NOT NULL,
    [Programme_Id] INT           NOT NULL,
    [Shape]        NVARCHAR (50) NULL,
    [Doors]        NVARCHAR (50) NULL,
    [Wheelbase]    NVARCHAR (50) NULL,
    [Active]       BIT           NULL,
    [Clone_Id]     INT           NULL,
    [Created_By]   NVARCHAR (8)  NULL,
    [Created_On]   DATETIME      NULL,
    [Updated_By]   NVARCHAR (8)  NULL,
    [Last_Updated] DATETIME      NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Body] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Body]
    ON [dbo].[OXO_Archived_Programme_Body]([Doc_Id] ASC, [Programme_Id] ASC);


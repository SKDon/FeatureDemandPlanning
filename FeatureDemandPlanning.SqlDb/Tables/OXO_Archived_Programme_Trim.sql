CREATE TABLE [dbo].[OXO_Archived_Programme_Trim] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [Doc_Id]       INT            NOT NULL,
    [Programme_Id] INT            NOT NULL,
    [Name]         NVARCHAR (500) NULL,
    [Abbreviation] NVARCHAR (50)  NULL,
    [Level]        NVARCHAR (500) NULL,
    [Active]       BIT            NULL,
    [Clone_Id]     INT            NULL,
    [Created_By]   NVARCHAR (8)   NULL,
    [Created_On]   DATETIME       NULL,
    [Updated_By]   NVARCHAR (8)   NULL,
    [Last_Updated] DATETIME       NULL,
    [DPCK]         NVARCHAR (10)  NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Trim] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Trim]
    ON [dbo].[OXO_Archived_Programme_Trim]([Doc_Id] ASC, [Programme_Id] ASC);


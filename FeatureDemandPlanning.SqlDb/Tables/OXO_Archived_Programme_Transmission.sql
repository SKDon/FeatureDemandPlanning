CREATE TABLE [dbo].[OXO_Archived_Programme_Transmission] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Doc_Id]       INT           NOT NULL,
    [Programme_Id] INT           NOT NULL,
    [Type]         NVARCHAR (50) NULL,
    [Drivetrain]   NVARCHAR (50) NULL,
    [Active]       BIT           NULL,
    [Clone_Id]     INT           NULL,
    [Created_By]   NVARCHAR (8)  NULL,
    [Created_On]   DATETIME      NULL,
    [Updated_By]   NVARCHAR (8)  NULL,
    [Last_Updated] DATETIME      NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Transmission] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Tran]
    ON [dbo].[OXO_Archived_Programme_Transmission]([Doc_Id] ASC, [Programme_Id] ASC);


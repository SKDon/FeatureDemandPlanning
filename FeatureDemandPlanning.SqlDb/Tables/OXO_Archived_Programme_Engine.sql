CREATE TABLE [dbo].[OXO_Archived_Programme_Engine] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [Doc_Id]          INT           NOT NULL,
    [Programme_Id]    INT           NOT NULL,
    [Size]            NVARCHAR (50) NOT NULL,
    [Cylinder]        NVARCHAR (50) NULL,
    [Turbo]           NVARCHAR (50) NULL,
    [Fuel_Type]       NVARCHAR (50) NULL,
    [Power]           NVARCHAR (50) NULL,
    [Electrification] NVARCHAR (50) NULL,
    [Active]          BIT           NULL,
    [Clone_Id]        INT           NULL,
    [Created_By]      NVARCHAR (8)  NULL,
    [Created_On]      DATETIME      NULL,
    [Updated_By]      NVARCHAR (8)  NULL,
    [Last_Updated]    DATETIME      NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Engine] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Engine]
    ON [dbo].[OXO_Archived_Programme_Engine]([Doc_Id] ASC, [Programme_Id] ASC);


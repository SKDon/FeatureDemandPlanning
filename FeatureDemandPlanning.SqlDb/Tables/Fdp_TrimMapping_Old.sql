CREATE TABLE [dbo].[Fdp_TrimMapping_Old] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [DerivativeCode] NVARCHAR (10)  NULL,
    [Trim]           NVARCHAR (100) NULL,
    [ProgrammeId]    INT            NULL,
    [TrimId]         INT            NULL,
    [EngineId]       INT            NULL,
    CONSTRAINT [PK_Fdp_TrimMapping] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Fdp_TrimMapping_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_Fdp_TrimMapping_OXO_Programme_Trim] FOREIGN KEY ([TrimId]) REFERENCES [dbo].[OXO_Programme_Trim] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_TrimMapping_Cover]
    ON [dbo].[Fdp_TrimMapping_Old]([DerivativeCode] ASC, [Trim] ASC);


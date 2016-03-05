CREATE TABLE [dbo].[Fdp_OxoDervivative] (
    [FdpOxoDervivativeId] INT           IDENTITY (1, 1) NOT NULL,
    [ProgrammeId]         INT           NOT NULL,
    [DerivativeCode]      NVARCHAR (20) NOT NULL,
    [BodyId]              INT           NOT NULL,
    [EngineId]            INT           NOT NULL,
    [TransmissionId]      INT           NOT NULL,
    CONSTRAINT [PK_FdpOxoDervivativeId] PRIMARY KEY CLUSTERED ([FdpOxoDervivativeId] ASC),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme_Body] FOREIGN KEY ([BodyId]) REFERENCES [dbo].[OXO_Programme_Body] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme_Engine] FOREIGN KEY ([EngineId]) REFERENCES [dbo].[OXO_Programme_Engine] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme_Transmission] FOREIGN KEY ([TransmissionId]) REFERENCES [dbo].[OXO_Programme_Transmission] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoDervivative_Cover]
    ON [dbo].[Fdp_OxoDervivative]([ProgrammeId] ASC, [BodyId] ASC, [EngineId] ASC, [TransmissionId] ASC);


CREATE TABLE [dbo].[Fdp_OxoDerivative] (
    [FdpOxoDerivativeId] INT           IDENTITY (1, 1) NOT NULL,
    [DocumentId]         INT           NOT NULL,
    [ProgrammeId]        INT           NOT NULL,
    [Gateway]            NVARCHAR (10) NOT NULL,
    [DerivativeCode]     NVARCHAR (20) NOT NULL,
    [BodyId]             INT           NOT NULL,
    [EngineId]           INT           NOT NULL,
    [TransmissionId]     INT           NOT NULL,
    [IsArchived]         BIT           CONSTRAINT [DF_Fdp_OxoDerivative_IsArchived] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FdpOxoDervivativeId] PRIMARY KEY CLUSTERED ([FdpOxoDerivativeId] ASC),
    CONSTRAINT [FK_Fdp_OxoDerivative_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme_Body] FOREIGN KEY ([BodyId]) REFERENCES [dbo].[OXO_Programme_Body] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme_Engine] FOREIGN KEY ([EngineId]) REFERENCES [dbo].[OXO_Programme_Engine] ([Id]),
    CONSTRAINT [FK_Fdp_OxoDervivative_OXO_Programme_Transmission] FOREIGN KEY ([TransmissionId]) REFERENCES [dbo].[OXO_Programme_Transmission] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoDervivative_Cover]
    ON [dbo].[Fdp_OxoDerivative]([ProgrammeId] ASC, [BodyId] ASC, [EngineId] ASC, [TransmissionId] ASC);


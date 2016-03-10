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
    CONSTRAINT [FK_Fdp_OxoDerivative_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_OxoDervivative_Cover]
    ON [dbo].[Fdp_OxoDerivative]([ProgrammeId] ASC, [BodyId] ASC, [EngineId] ASC, [TransmissionId] ASC);


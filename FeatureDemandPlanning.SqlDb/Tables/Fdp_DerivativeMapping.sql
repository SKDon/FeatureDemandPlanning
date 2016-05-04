CREATE TABLE [dbo].[Fdp_DerivativeMapping] (
    [FdpDerivativeMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]              DATETIME       CONSTRAINT [DF_Fdp_DerivativeMapping_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              NVARCHAR (16)  CONSTRAINT [DF_Fdp_DerivativeMapping_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ProgrammeId]            INT            NOT NULL,
    [Gateway]                NVARCHAR (100) NOT NULL,
    [ImportDerivativeCode]   NVARCHAR (20)  NOT NULL,
    [DerivativeCode]         NVARCHAR (10)  NOT NULL,
    [BodyId]                 INT            NOT NULL,
    [EngineId]               INT            NOT NULL,
    [TransmissionId]         INT            NOT NULL,
    [IsActive]               BIT            CONSTRAINT [DF_Fdp_DerivativeMapping_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]              DATETIME       NULL,
    [UpdatedBy]              NVARCHAR (16)  NULL,
    [DocumentId]             INT            NOT NULL,
    CONSTRAINT [PK_FdpDerivativeMapping] PRIMARY KEY CLUSTERED ([FdpDerivativeMappingId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Fdp_DerivativeMapping_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_DerivativeMapping_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);










GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_DerivativeMapping_TransmissionId]
    ON [dbo].[Fdp_DerivativeMapping]([TransmissionId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_DerivativeMapping_ImportDerivativeCode]
    ON [dbo].[Fdp_DerivativeMapping]([ImportDerivativeCode] ASC, [ProgrammeId] ASC)
    INCLUDE([DerivativeCode]);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_DerivativeMapping_EngineId]
    ON [dbo].[Fdp_DerivativeMapping]([EngineId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_DerivativeMapping_BodyId]
    ON [dbo].[Fdp_DerivativeMapping]([BodyId] ASC);


CREATE TABLE [dbo].[Fdp_DerivativeMapping] (
    [FdpDerivativeMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [ImportDerivativeCode]   NVARCHAR (20) NULL,
    [ProgrammeId]            INT           NULL,
    [BodyId]                 INT           NULL,
    [EngineId]               INT           NULL,
    [TransmissionId]         INT           NULL,
    PRIMARY KEY CLUSTERED ([FdpDerivativeMappingId] ASC)
);


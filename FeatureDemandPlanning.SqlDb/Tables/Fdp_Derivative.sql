CREATE TABLE [dbo].[Fdp_Derivative] (
    [FdpDerivativeId]         INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]               DATETIME       CONSTRAINT [DF_Fdp_Derivative_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_Derivative_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ProgrammeId]             INT            NOT NULL,
    [Gateway]                 NVARCHAR (100) NOT NULL,
    [DerivativeCode]          NCHAR (20)     NOT NULL,
    [BodyId]                  INT            NOT NULL,
    [EngineId]                INT            NOT NULL,
    [TransmissionId]          INT            NOT NULL,
    [IsActive]                BIT            CONSTRAINT [DF_Fdp_Derivative_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]               DATETIME       NULL,
    [UpdatedBy]               NVARCHAR (16)  NULL,
    [OriginalFdpDerivativeId] INT            NULL,
    CONSTRAINT [PK_Fdp_Derivative] PRIMARY KEY CLUSTERED ([FdpDerivativeId] ASC),
    CONSTRAINT [FK_Fdp_Derivative_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_Fdp_Derivative_OXO_Programme_Body] FOREIGN KEY ([BodyId]) REFERENCES [dbo].[OXO_Programme_Body] ([Id]),
    CONSTRAINT [FK_Fdp_Derivative_OXO_Programme_Engine] FOREIGN KEY ([EngineId]) REFERENCES [dbo].[OXO_Programme_Engine] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Derivative_DerivativeCode]
    ON [dbo].[Fdp_Derivative]([DerivativeCode] ASC, [ProgrammeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Derivative_OriginalFdpDerivativeId]
    ON [dbo].[Fdp_Derivative]([OriginalFdpDerivativeId] ASC);


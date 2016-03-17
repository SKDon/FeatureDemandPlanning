CREATE TABLE [dbo].[Fdp_ImportErrorExclusion] (
    [FdpImportErrorExclusionId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]                 DATETIME       CONSTRAINT [DF_Fdp_ImportErrorExclusion_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                 NVARCHAR (16)  CONSTRAINT [DF_Fdp_ImportErrorExclusion_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [DocumentId]                INT            NOT NULL,
    [ProgrammeId]               INT            NOT NULL,
    [Gateway]                   NVARCHAR (100) NOT NULL,
    [FdpImportErrorTypeId]      INT            NOT NULL,
    [SubTypeId]                 INT            NULL,
    [ErrorMessage]              NVARCHAR (MAX) NULL,
    [AdditionalData]            NVARCHAR (MAX) NULL,
    [IsActive]                  BIT            CONSTRAINT [DF__Fdp_Impor__IsAct__67001F3A] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]                 DATETIME       NULL,
    [UpdatedBy]                 NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_ImportErrorExclusion] PRIMARY KEY CLUSTERED ([FdpImportErrorExclusionId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Fdp_ImportErrorExclusion_Fdp_ImportErrorType] FOREIGN KEY ([FdpImportErrorTypeId]) REFERENCES [dbo].[Fdp_ImportErrorType] ([FdpImportErrorTypeId]),
    CONSTRAINT [FK_Fdp_ImportErrorExclusion_Fdp_ImportErrorType1] FOREIGN KEY ([SubTypeId]) REFERENCES [dbo].[Fdp_ImportErrorType] ([FdpImportErrorTypeId]),
    CONSTRAINT [FK_Fdp_ImportErrorExclusion_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_ImportErrorExclusion_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportErrorExclusion_ProgrammeId_ErrorMessage]
    ON [dbo].[Fdp_ImportErrorExclusion]([ProgrammeId] ASC)
    INCLUDE([ErrorMessage]);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportErrorExclusion_Cover]
    ON [dbo].[Fdp_ImportErrorExclusion]([DocumentId] ASC, [ProgrammeId] ASC, [Gateway] ASC, [FdpImportErrorTypeId] ASC, [SubTypeId] ASC, [IsActive] ASC);


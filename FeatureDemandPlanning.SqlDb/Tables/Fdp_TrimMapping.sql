CREATE TABLE [dbo].[Fdp_TrimMapping] (
    [FdpTrimMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]        DATETIME       CONSTRAINT [DF_Fdp_TrimMapping_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        NVARCHAR (16)  CONSTRAINT [DF_Fdp_TrimMapping_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ImportTrim]       NVARCHAR (100) NOT NULL,
    [DocumentId]       INT            NOT NULL,
    [ProgrammeId]      INT            NOT NULL,
    [Gateway]          NVARCHAR (100) NOT NULL,
    [BMC]              NVARCHAR (20)  NULL,
    [TrimId]           INT            NULL,
    [FdpTrimId]        INT            NULL,
    [IsActive]         BIT            CONSTRAINT [DF_Fdp_TrimMapping_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]        DATETIME       NULL,
    [UpdatedBy]        NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_TrimMapping] PRIMARY KEY CLUSTERED ([FdpTrimMappingId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Fdp_TrimMapping_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id])
);












GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_TrimMapping_TrimId]
    ON [dbo].[Fdp_TrimMapping]([TrimId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_TrimMapping_ImportTrim]
    ON [dbo].[Fdp_TrimMapping]([ProgrammeId] ASC, [ImportTrim] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_TrimMapping_DocumentId]
    ON [dbo].[Fdp_TrimMapping]([DocumentId] ASC);


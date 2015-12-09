CREATE TABLE [dbo].[Fdp_Import] (
    [FdpImportId]      INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]        DATETIME       CONSTRAINT [DF_Fdp_Import_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        NVARCHAR (16)  CONSTRAINT [DF_Fdp_Import_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpImportQueueId] INT            NOT NULL,
    [ProgrammeId]      INT            NOT NULL,
    [Gateway]          NVARCHAR (100) NOT NULL,
    [DocumentId]       INT            NOT NULL,
    CONSTRAINT [PK_Fdp_Import] PRIMARY KEY CLUSTERED ([FdpImportId] ASC),
    CONSTRAINT [FK_Fdp_Import_ImportQueue] FOREIGN KEY ([FdpImportQueueId]) REFERENCES [dbo].[Fdp_ImportQueue] ([FdpImportQueueId]),
    CONSTRAINT [FK_Fdp_Import_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_Import_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Import_Cover]
    ON [dbo].[Fdp_Import]([ProgrammeId] ASC, [Gateway] ASC, [DocumentId] ASC);


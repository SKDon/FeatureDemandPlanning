CREATE TABLE [dbo].[Fdp_Import] (
    [FdpImportId]   INT            IDENTITY (1, 1) NOT NULL,
    [ImportQueueId] INT            NOT NULL,
    [ProgrammeId]   INT            NOT NULL,
    [Gateway]       NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Fdp_Import] PRIMARY KEY CLUSTERED ([FdpImportId] ASC),
    CONSTRAINT [FK_Fdp_Import_ImportQueue] FOREIGN KEY ([ImportQueueId]) REFERENCES [dbo].[ImportQueue] ([ImportQueueId]),
    CONSTRAINT [FK_Fdp_Import_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


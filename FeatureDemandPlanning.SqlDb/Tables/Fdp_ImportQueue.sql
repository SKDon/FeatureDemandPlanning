CREATE TABLE [dbo].[Fdp_ImportQueue] (
    [FdpImportQueueId]  INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]         DATETIME       CONSTRAINT [DF_Fdp_ImportQueue_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16)  CONSTRAINT [DF_Fdp_ImportQueue_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpImportTypeId]   INT            NOT NULL,
    [FdpImportStatusId] INT            NOT NULL,
    [OriginalFileName]  NVARCHAR (100) NULL,
    [FilePath]          NVARCHAR (MAX) NOT NULL,
    [UpdatedOn]         DATETIME       NULL,
    CONSTRAINT [PK_Fdp_ImportQueue] PRIMARY KEY CLUSTERED ([FdpImportQueueId] ASC),
    CONSTRAINT [FK_ImportQueue_ImportStatus] FOREIGN KEY ([FdpImportStatusId]) REFERENCES [dbo].[Fdp_ImportStatus] ([FdpImportStatusId]),
    CONSTRAINT [FK_ImportQueue_ImportType] FOREIGN KEY ([FdpImportTypeId]) REFERENCES [dbo].[Fdp_ImportType] ([FdpImportTypeId])
);


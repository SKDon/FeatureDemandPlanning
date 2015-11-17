CREATE TABLE [dbo].[Fdp_ImportQueueError] (
    [FdpImportQueueErrorId] INT            IDENTITY (1, 1) NOT NULL,
    [ErrorOn]               DATETIME       CONSTRAINT [DF_Fdp_ImportQueueError_ErrorOn] DEFAULT (getdate()) NOT NULL,
    [ErrorBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_ImportQueueError_ErrorBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpImportQueueId]      INT            NOT NULL,
    [Error]                 NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_ImportQueueError] PRIMARY KEY CLUSTERED ([FdpImportQueueErrorId] ASC),
    CONSTRAINT [FK_Fdp_ImportQueueError_Fdp_ImportQueue] FOREIGN KEY ([FdpImportQueueId]) REFERENCES [dbo].[Fdp_ImportQueue] ([FdpImportQueueId])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportQueueError_FdpImportQueueId]
    ON [dbo].[Fdp_ImportQueueError]([FdpImportQueueId] ASC);


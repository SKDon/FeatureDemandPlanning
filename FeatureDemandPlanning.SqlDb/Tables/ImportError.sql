CREATE TABLE [dbo].[ImportError] (
    [ImportErrorId] INT            NOT NULL,
    [ImportQueueId] INT            NOT NULL,
    [ErrorOn]       DATETIME       NOT NULL,
    [Error]         NVARCHAR (MAX) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_ImportError_ImportQueueId]
    ON [dbo].[ImportError]([ImportQueueId] ASC);


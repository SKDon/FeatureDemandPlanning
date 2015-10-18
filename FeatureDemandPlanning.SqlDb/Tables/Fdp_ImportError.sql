CREATE TABLE [dbo].[Fdp_ImportError] (
    [FdpImportErrorId]     INT            IDENTITY (1, 1) NOT NULL,
    [ImportQueueId]        INT            NOT NULL,
    [LineNumber]           INT            NOT NULL,
    [ErrorOn]              DATETIME       CONSTRAINT [DF_Fdp_ImportError_ErrorOn] DEFAULT (getdate()) NOT NULL,
    [FdpImportErrorTypeId] INT            NOT NULL,
    [ErrorMessage]         NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_ImportError] PRIMARY KEY CLUSTERED ([FdpImportErrorId] ASC),
    CONSTRAINT [FK_Fdp_ImportError_Fdp_ImportErrorType] FOREIGN KEY ([FdpImportErrorTypeId]) REFERENCES [dbo].[Fdp_ImportErrorType] ([FdpImportErrorTypeId])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_ImportError_FdpImportErrorTypeId]
    ON [dbo].[Fdp_ImportError]([FdpImportErrorTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportData_ImportQueueId]
    ON [dbo].[Fdp_ImportError]([ImportQueueId] ASC, [LineNumber] ASC);


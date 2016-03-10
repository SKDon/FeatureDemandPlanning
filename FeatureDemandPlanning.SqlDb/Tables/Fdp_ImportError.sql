CREATE TABLE [dbo].[Fdp_ImportError] (
    [FdpImportErrorId]     INT            IDENTITY (1, 1) NOT NULL,
    [FdpImportQueueId]     INT            NOT NULL,
    [LineNumber]           INT            NOT NULL,
    [ErrorOn]              DATETIME       CONSTRAINT [DF_Fdp_ImportError_ErrorOn] DEFAULT (getdate()) NOT NULL,
    [FdpImportErrorTypeId] INT            NOT NULL,
    [ErrorMessage]         NVARCHAR (MAX) NOT NULL,
    [IsExcluded]           BIT            CONSTRAINT [DF__Fdp_Impor__IsExc__1B13F4C6] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]            DATETIME       NULL,
    [UpdatedBy]            NVARCHAR (16)  NULL,
    [AdditionalData]       NVARCHAR (100) NULL,
    CONSTRAINT [PK_Fdp_ImportError] PRIMARY KEY CLUSTERED ([FdpImportErrorId] ASC),
    CONSTRAINT [FK_Fdp_ImportError_Fdp_ImportErrorType] FOREIGN KEY ([FdpImportErrorTypeId]) REFERENCES [dbo].[Fdp_ImportErrorType] ([FdpImportErrorTypeId])
);










GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_ImportError_FdpImportErrorTypeId]
    ON [dbo].[Fdp_ImportError]([FdpImportErrorTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportData_ImportQueueId]
    ON [dbo].[Fdp_ImportError]([FdpImportQueueId] ASC, [LineNumber] ASC);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportError_Cover]
    ON [dbo].[Fdp_ImportError]([FdpImportQueueId] ASC, [IsExcluded] ASC)
    INCLUDE([FdpImportErrorId], [LineNumber], [FdpImportErrorTypeId], [ErrorMessage]);


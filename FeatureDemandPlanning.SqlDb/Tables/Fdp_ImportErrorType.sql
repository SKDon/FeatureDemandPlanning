CREATE TABLE [dbo].[Fdp_ImportErrorType] (
    [FdpImportErrorTypeId] INT            NOT NULL,
    [Type]                 NVARCHAR (50)  NOT NULL,
    [Description]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_ImportErrorType] PRIMARY KEY CLUSTERED ([FdpImportErrorTypeId] ASC)
);


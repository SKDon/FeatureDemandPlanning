CREATE TABLE [dbo].[Fdp_ImportStatus] (
    [FdpImportStatusId] INT            NOT NULL,
    [Status]            NVARCHAR (50)  NOT NULL,
    [Description]       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_ImportStatus] PRIMARY KEY CLUSTERED ([FdpImportStatusId] ASC)
);


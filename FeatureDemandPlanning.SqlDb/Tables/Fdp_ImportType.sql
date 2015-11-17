CREATE TABLE [dbo].[Fdp_ImportType] (
    [FdpImportTypeId] INT            NOT NULL,
    [Type]            NVARCHAR (25)  NOT NULL,
    [Description]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ImportType] PRIMARY KEY CLUSTERED ([FdpImportTypeId] ASC)
);


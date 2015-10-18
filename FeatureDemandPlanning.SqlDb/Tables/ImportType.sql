CREATE TABLE [dbo].[ImportType] (
    [ImportTypeId] INT            NOT NULL,
    [Type]         NVARCHAR (25)  NOT NULL,
    [Description]  NVARCHAR (MAX) NOT NULL,
    [PackageName]  NVARCHAR (255) NOT NULL,
    CONSTRAINT [PK_ImportType] PRIMARY KEY CLUSTERED ([ImportTypeId] ASC)
);


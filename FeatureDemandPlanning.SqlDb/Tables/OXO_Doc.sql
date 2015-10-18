CREATE TABLE [dbo].[OXO_Doc] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Programme_Id] INT             NULL,
    [Version_Id]   NUMERIC (10, 1) NULL,
    [Owner]        NVARCHAR (8)    NULL,
    [Created_By]   NVARCHAR (50)   NULL,
    [Created_On]   DATETIME        NULL,
    [Updated_By]   NVARCHAR (50)   NULL,
    [Last_Updated] DATETIME        NULL,
    [Gateway]      NVARCHAR (50)   NULL,
    [Status]       NVARCHAR (50)   NULL,
    [Archived]     BIT             NULL,
    CONSTRAINT [PK_OXO_Doc] PRIMARY KEY CLUSTERED ([Id] ASC)
);


CREATE TABLE [dbo].[OXO_EMAIL_TEMPLATE] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Event]        NVARCHAR (50)   NOT NULL,
    [Subject]      NVARCHAR (4000) NULL,
    [Body]         NTEXT           NULL,
    [Created_By]   NVARCHAR (50)   NULL,
    [Created_On]   DATETIME        NULL,
    [Updated_By]   NVARCHAR (50)   NULL,
    [Last_Updated] DATETIME        NULL,
    CONSTRAINT [PK_OXO_EMAIL_TEMPLATE] PRIMARY KEY CLUSTERED ([Id] ASC)
);


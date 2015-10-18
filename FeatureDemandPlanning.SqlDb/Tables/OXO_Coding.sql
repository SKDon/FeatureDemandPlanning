CREATE TABLE [dbo].[OXO_Coding] (
    [Id]            INT             NOT NULL,
    [Code]          NVARCHAR (50)   NOT NULL,
    [Description]   NVARCHAR (500)  NOT NULL,
    [Notes]         NVARCHAR (2000) NULL,
    [Display_Order] INT             NULL,
    [Active]        BIT             NULL,
    [Created_By]    NVARCHAR (8)    NULL,
    [Created_On]    DATETIME        NULL,
    [Updated_By]    NVARCHAR (8)    NULL,
    [Last_Updated]  DATETIME        NULL,
    [TEST]          INT             NULL,
    CONSTRAINT [PK_OXO_Coding] PRIMARY KEY CLUSTERED ([Id] ASC)
);


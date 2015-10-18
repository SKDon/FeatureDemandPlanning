CREATE TABLE [dbo].[OXO_Reference_List] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Code]          NVARCHAR (50)  NULL,
    [Description]   NVARCHAR (500) NULL,
    [List_Name]     NVARCHAR (100) NULL,
    [Display_Order] INT            NULL,
    [Active]        BIT            NULL,
    [Created_By]    NVARCHAR (8)   NULL,
    [Created_On]    DATETIME       CONSTRAINT [DF_OXO_Reference_List_Created_On] DEFAULT (getdate()) NULL,
    [Updated_By]    NVARCHAR (8)   NULL,
    [Last_Updated]  DATETIME       NULL,
    CONSTRAINT [PK_OXO_Reference_List] PRIMARY KEY CLUSTERED ([Id] ASC)
);


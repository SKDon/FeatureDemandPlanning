CREATE TABLE [dbo].[OXO_Permission_Backup] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [CDSID]        NVARCHAR (50)  NULL,
    [Object_Type]  NVARCHAR (500) NULL,
    [Object_Id]    INT            NULL,
    [Object_Val]   NVARCHAR (500) NULL,
    [Operation]    NVARCHAR (500) NULL,
    [Created_By]   NVARCHAR (50)  NULL,
    [Created_On]   DATETIME       NULL,
    [Updated_By]   NVARCHAR (50)  NULL,
    [Last_Updated] DATETIME       NULL,
    CONSTRAINT [PK_OXO_Permission_Backup] PRIMARY KEY CLUSTERED ([Id] ASC)
);


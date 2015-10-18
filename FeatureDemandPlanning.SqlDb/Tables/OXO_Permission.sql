CREATE TABLE [dbo].[OXO_Permission] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [CDSID]        NVARCHAR (50)  NULL,
    [Object_Type]  NVARCHAR (50)  NULL,
    [Object_Id]    INT            NULL,
    [Object_Val]   NVARCHAR (500) NULL,
    [Operation]    NVARCHAR (25)  NULL,
    [Created_By]   NVARCHAR (50)  NULL,
    [Created_On]   DATETIME       NULL,
    [Updated_By]   NVARCHAR (50)  NULL,
    [Last_Updated] DATETIME       NULL,
    CONSTRAINT [PK_OXO_Permission] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Permission_FdpPermissionOperation] FOREIGN KEY ([Object_Type], [Operation]) REFERENCES [dbo].[Fdp_PermissionOperation] ([FdpPermissionObjectType], [Operation])
);


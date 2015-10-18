CREATE TABLE [dbo].[OXO_Vehicle] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (500) NOT NULL,
    [AKA]            NVARCHAR (500) NOT NULL,
    [Display_Format] NVARCHAR (500) NULL,
    [Make]           NVARCHAR (500) NULL,
    [Active]         BIT            NULL,
    [Created_By]     NVARCHAR (8)   NULL,
    [Created_On]     DATETIME       NULL,
    [Updated_By]     NVARCHAR (8)   NULL,
    [Last_Updated]   DATETIME       NULL,
    CONSTRAINT [PK_OXO_Vehicle] PRIMARY KEY CLUSTERED ([Id] ASC)
);


CREATE TABLE [dbo].[OXO_Master_Market] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (500) NOT NULL,
    [WHD]          NVARCHAR (50)  NULL,
    [PAR_X]        NVARCHAR (500) NULL,
    [PAR_L]        NVARCHAR (500) NULL,
    [Brand]        NVARCHAR (50)  NULL,
    [Territory]    NVARCHAR (50)  NULL,
    [WERSCode]     NVARCHAR (50)  NULL,
    [Active]       BIT            NULL,
    [Created_By]   NVARCHAR (8)   NULL,
    [Created_On]   DATETIME       NULL,
    [Updated_By]   NVARCHAR (8)   NULL,
    [Last_Updated] DATETIME       NULL,
    CONSTRAINT [PK_OXO_Master_Country] PRIMARY KEY CLUSTERED ([Id] ASC)
);


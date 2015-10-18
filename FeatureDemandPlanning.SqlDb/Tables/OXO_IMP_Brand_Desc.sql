CREATE TABLE [dbo].[OXO_IMP_Brand_Desc] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [Feat_Code]    NVARCHAR (10)   NOT NULL,
    [Brand]        NVARCHAR (10)   NOT NULL,
    [Brand_Desc]   NVARCHAR (1000) NOT NULL,
    [Status]       BIT             NULL,
    [Created_By]   NVARCHAR (8)    NULL,
    [Created_On]   DATETIME        NULL,
    [Updated_By]   NVARCHAR (8)    NULL,
    [Last_Updated] DATETIME        NULL,
    CONSTRAINT [PK_OXO_IMP_Brand_Desc] PRIMARY KEY CLUSTERED ([Id] ASC)
);


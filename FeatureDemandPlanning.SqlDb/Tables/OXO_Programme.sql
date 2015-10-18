CREATE TABLE [dbo].[OXO_Programme] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [Vehicle_Id]      INT             NULL,
    [Model_Year]      NVARCHAR (50)   NULL,
    [Notes]           NVARCHAR (2000) NULL,
    [Product_Manager] NVARCHAR (8)    NULL,
    [RSG_UID]         NVARCHAR (500)  NULL,
    [OXO_Enabled]     BIT             NULL,
    [Active]          BIT             NULL,
    [Created_By]      NVARCHAR (8)    NULL,
    [Created_On]      DATETIME        NULL,
    [Updated_By]      NVARCHAR (8)    NULL,
    [Last_Updated]    DATETIME        NULL,
    [Use_OA_Code]     BIT             NULL,
    CONSTRAINT [PK_OXO_Programme] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Programme_OXO_Vehicle] FOREIGN KEY ([Vehicle_Id]) REFERENCES [dbo].[OXO_Vehicle] ([Id])
);


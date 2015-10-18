CREATE TABLE [dbo].[tmp_OXO_Item_Data] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Section]            NVARCHAR (50)   NOT NULL,
    [Model_Id]           INT             NOT NULL,
    [Market_Group_Id]    INT             NOT NULL,
    [Market_Id]          INT             NOT NULL,
    [Feature_Id]         INT             NULL,
    [OXO_Doc_Id]         INT             NULL,
    [OXO_Code]           NVARCHAR (50)   NULL,
    [Take_Rate]          DECIMAL (18, 2) NULL,
    [Historic_Take_Rate] DECIMAL (18, 2) NULL,
    [Active]             BIT             NULL,
    [Created_By]         NVARCHAR (8)    NULL,
    [Created_On]         DATETIME        NULL,
    [Updated_By]         NVARCHAR (8)    NULL,
    [Last_Updated]       DATETIME        NULL,
    CONSTRAINT [PK_tmp_OXO_Item_Data] PRIMARY KEY CLUSTERED ([Id] ASC)
);


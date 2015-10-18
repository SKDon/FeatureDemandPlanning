CREATE TABLE [dbo].[OXO_Change_Set] (
    [Set_Id]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [OXO_Doc_Id]   INT             NULL,
    [Section]      NVARCHAR (50)   NULL,
    [Reminder]     NVARCHAR (500)  NULL,
    [Is_Important] BIT             NULL,
    [Is_Starred]   BIT             NULL,
    [Updated_By]   NVARCHAR (8)    NULL,
    [Last_Updated] DATETIME        NULL,
    [Version_Id]   NUMERIC (10, 1) NULL,
    CONSTRAINT [PK_OXO_ChangeSet] PRIMARY KEY CLUSTERED ([Set_Id] ASC)
);


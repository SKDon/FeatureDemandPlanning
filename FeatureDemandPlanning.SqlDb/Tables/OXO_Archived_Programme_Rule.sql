CREATE TABLE [dbo].[OXO_Archived_Programme_Rule] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Doc_Id]        INT            NULL,
    [Programme_Id]  INT            NULL,
    [Rule_Category] NVARCHAR (50)  NOT NULL,
    [Rule_Group]    NVARCHAR (50)  NOT NULL,
    [Rule_Assert]   NVARCHAR (500) NULL,
    [Rule_Report]   NVARCHAR (500) NULL,
    [Rule_Response] NVARCHAR (500) NOT NULL,
    [Owner]         NVARCHAR (50)  NOT NULL,
    [Approved]      BIT            NULL,
    [Active]        BIT            NULL,
    [Clone_Id]      INT            NULL,
    [Created_By]    VARCHAR (8)    NOT NULL,
    [Created_On]    DATETIME       NOT NULL,
    [Updated_By]    VARCHAR (8)    NULL,
    [Last_Updated]  DATETIME       NULL,
    [Rule_Reason]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Rule] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Pack]
    ON [dbo].[OXO_Archived_Programme_Rule]([Doc_Id] ASC, [Programme_Id] ASC);


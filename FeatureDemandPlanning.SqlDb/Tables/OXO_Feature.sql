CREATE TABLE [dbo].[OXO_Feature] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [Description]       NVARCHAR (500)  NOT NULL,
    [Notes]             NVARCHAR (2000) NULL,
    [PROFET_JAG]        NVARCHAR (50)   NULL,
    [PROFET_LR]         NVARCHAR (50)   NULL,
    [WERS]              NVARCHAR (50)   NULL,
    [Active]            BIT             NULL,
    [Feature_Group]     NVARCHAR (500)  NOT NULL,
    [Feature_EFG]       NVARCHAR (50)   NULL,
    [Created_By]        NVARCHAR (8)    NULL,
    [Created_On]        DATETIME        NULL,
    [Updated_By]        NVARCHAR (8)    NULL,
    [Last_Updated]      DATETIME        NULL,
    [JLR_Code]          NVARCHAR (50)   NULL,
    [Feature_Sub_Group] NVARCHAR (500)  NULL,
    [MFD_JLRCode]       NVARCHAR (50)   NULL,
    [MFD_EFG]           NVARCHAR (50)   NULL,
    CONSTRAINT [PK_OXO_Minor_Feature] PRIMARY KEY CLUSTERED ([Id] ASC)
);


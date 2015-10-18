CREATE TABLE [dbo].[OXO_Programme_File] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [Programme_Id]  INT             NOT NULL,
    [File_Name]     VARCHAR (100)   NULL,
    [File_Type]     VARCHAR (20)    NULL,
    [File_Size]     INT             NULL,
    [File_Content]  IMAGE           NULL,
    [Created_By]    VARCHAR (8)     NOT NULL,
    [Created_On]    DATETIME        NOT NULL,
    [Updated_By]    VARCHAR (8)     NULL,
    [Last_Updated]  DATETIME        NULL,
    [File_Ext]      VARCHAR (4)     NULL,
    [File_Category] NVARCHAR (100)  NULL,
    [File_Comment]  NVARCHAR (2000) NULL,
    [Gateway]       NVARCHAR (50)   NULL,
    [PACN]          NVARCHAR (10)   NULL,
    [GUID]          NVARCHAR (50)   NULL,
    CONSTRAINT [PK_UploadedFiles] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [Idx_Prog_File]
    ON [dbo].[OXO_Programme_File]([Programme_Id] ASC);


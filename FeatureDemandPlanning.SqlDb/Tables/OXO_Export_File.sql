CREATE TABLE [dbo].[OXO_Export_File] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [GUID]         NVARCHAR (50) NOT NULL,
    [File_Content] IMAGE         NOT NULL,
    [File_Size]    INT           NOT NULL,
    [Created_On]   DATETIME      CONSTRAINT [DF_OXO_Export_File_Created_On] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportFiles] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Export_GUID]
    ON [dbo].[OXO_Export_File]([GUID] ASC);


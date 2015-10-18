CREATE TABLE [dbo].[OXO_Temp_Working_Data] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [GUID]            NVARCHAR (100) NULL,
    [Section]         NVARCHAR (50)  NOT NULL,
    [Model_Id]        INT            NULL,
    [Market_Id]       INT            NULL,
    [Market_Group_Id] INT            NULL,
    [Feature_Id]      INT            NULL,
    [Pack_Id]         INT            NULL,
    [OXO_Doc_Id]      INT            NULL,
    [OXO_Code]        NVARCHAR (50)  NULL,
    [Reminder]        NVARCHAR (500) NULL,
    CONSTRAINT [PK_OXO_Temp_Working_Data] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_GUID]
    ON [dbo].[OXO_Temp_Working_Data]([GUID] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Doc_Section]
    ON [dbo].[OXO_Temp_Working_Data]([OXO_Doc_Id] ASC, [GUID] ASC, [Section] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Model_Market]
    ON [dbo].[OXO_Temp_Working_Data]([Model_Id] ASC, [Market_Id] ASC, [Market_Group_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Model_Feat]
    ON [dbo].[OXO_Temp_Working_Data]([Model_Id] ASC, [Feature_Id] ASC, [Pack_Id] ASC);


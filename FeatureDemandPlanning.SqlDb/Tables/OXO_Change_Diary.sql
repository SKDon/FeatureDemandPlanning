CREATE TABLE [dbo].[OXO_Change_Diary] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [OXO_Doc_Id]           INT            NULL,
    [Programme_Id]         INT            NULL,
    [Version_Info]         NVARCHAR (100) NULL,
    [Entry_Header]         NVARCHAR (MAX) NULL,
    [Entry_Date]           DATETIME       NULL,
    [Markets]              NVARCHAR (MAX) NULL,
    [Models]               NVARCHAR (MAX) NULL,
    [Features]             NVARCHAR (MAX) NULL,
    [Current_Fitment]      NVARCHAR (50)  NULL,
    [Proposed_Fitment]     NVARCHAR (50)  NULL,
    [Comment]              NVARCHAR (MAX) NULL,
    [PACN]                 NVARCHAR (100) NULL,
    [ETracker]             NVARCHAR (100) NULL,
    [Order_Call]           NVARCHAR (MAX) NULL,
    [Build_Effective_Date] DATETIME       NULL,
    [Requester]            NVARCHAR (100) NULL,
    [Pricing_Status]       NVARCHAR (500) NULL,
    [Digital_Status]       NVARCHAR (500) NULL,
    CONSTRAINT [PK_OXO_Change_Diary] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Change_Diary_Entry_Date_Version_Info]
    ON [dbo].[OXO_Change_Diary]([Entry_Date] DESC, [Version_Info] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Change_Diary_OXO_Doc_Id]
    ON [dbo].[OXO_Change_Diary]([OXO_Doc_Id] ASC);


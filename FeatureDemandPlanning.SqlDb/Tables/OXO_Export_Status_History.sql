CREATE TABLE [dbo].[OXO_Export_Status_History] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Request_Id]  INT           NOT NULL,
    [Status]      NVARCHAR (50) NULL,
    [Status_Date] DATETIME      NULL,
    CONSTRAINT [PK_OXO_Export_Status_History] PRIMARY KEY CLUSTERED ([Id] ASC)
);


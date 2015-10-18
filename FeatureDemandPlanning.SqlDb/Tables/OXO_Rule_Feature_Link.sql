CREATE TABLE [dbo].[OXO_Rule_Feature_Link] (
    [Rule_Id]      INT         NOT NULL,
    [Programme_Id] INT         NOT NULL,
    [Feature_Id]   INT         NOT NULL,
    [Created_By]   VARCHAR (8) NOT NULL,
    [Created_On]   DATETIME    NOT NULL,
    [Updated_By]   VARCHAR (8) NULL,
    [Last_Updated] DATETIME    NULL,
    CONSTRAINT [PK_OXO_Rule_Feature_Link_1] PRIMARY KEY CLUSTERED ([Rule_Id] ASC, [Programme_Id] ASC, [Feature_Id] ASC),
    CONSTRAINT [FK_OXO_Rule_Feature_Link_OXO_Programme] FOREIGN KEY ([Programme_Id]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_OXO_Rule_Feature_Link_OXO_Programme_Rule] FOREIGN KEY ([Rule_Id]) REFERENCES [dbo].[OXO_Programme_Rule] ([Id])
);


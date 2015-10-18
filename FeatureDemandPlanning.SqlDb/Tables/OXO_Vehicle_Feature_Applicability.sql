CREATE TABLE [dbo].[OXO_Vehicle_Feature_Applicability] (
    [Vehicle_Id] INT          NOT NULL,
    [Feature_id] INT          NOT NULL,
    [Created_By] NVARCHAR (8) NULL,
    [Created_On] DATETIME     NULL,
    CONSTRAINT [PK_OXO_Vehicle_Feature_Applicability] PRIMARY KEY CLUSTERED ([Vehicle_Id] ASC, [Feature_id] ASC)
);


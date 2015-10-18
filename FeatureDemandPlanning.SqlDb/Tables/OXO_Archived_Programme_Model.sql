CREATE TABLE [dbo].[OXO_Archived_Programme_Model] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [Doc_Id]          INT           NOT NULL,
    [Programme_Id]    INT           NOT NULL,
    [Body_Id]         INT           NOT NULL,
    [Engine_Id]       INT           NOT NULL,
    [Transmission_Id] INT           NOT NULL,
    [Trim_Id]         INT           NOT NULL,
    [Active]          BIT           NULL,
    [Clone_Id]        INT           NULL,
    [Created_By]      NVARCHAR (8)  NULL,
    [Created_On]      DATETIME      NULL,
    [Updated_By]      NVARCHAR (8)  NULL,
    [Last_Updated]    DATETIME      NULL,
    [BMC]             NVARCHAR (10) NULL,
    [CoA]             NVARCHAR (10) NULL,
    [KD]              BIT           NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Variant] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Model]
    ON [dbo].[OXO_Archived_Programme_Model]([Doc_Id] ASC, [Programme_Id] ASC, [Active] ASC);


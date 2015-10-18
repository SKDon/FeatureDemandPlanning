CREATE TABLE [dbo].[OXO_System_User] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [CDSID]          NVARCHAR (10)  NOT NULL,
    [Title]          NVARCHAR (50)  NULL,
    [First_Names]    NVARCHAR (100) NULL,
    [Surname]        NVARCHAR (100) NOT NULL,
    [Department]     NVARCHAR (100) NULL,
    [Job_Title]      NVARCHAR (100) NULL,
    [Senior_Manager] NVARCHAR (300) NULL,
    [Registered_On]  DATETIME       NULL,
    [Is_Admin]       BIT            NULL,
    [Created_By]     NVARCHAR (8)   NULL,
    [Created_On]     DATETIME       CONSTRAINT [DF_OXO_System_User_Created_On] DEFAULT (getdate()) NULL,
    [Updated_By]     NVARCHAR (8)   NULL,
    [Last_Updated]   DATETIME       NULL,
    CONSTRAINT [PK_OXO_SYSTEM_USER] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_SysUser_CDSID]
    ON [dbo].[OXO_System_User]([CDSID] ASC);


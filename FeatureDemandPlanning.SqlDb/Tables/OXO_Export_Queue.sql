CREATE TABLE [dbo].[OXO_Export_Queue] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [GUID]         NVARCHAR (50)  NOT NULL,
    [Doc_Id]       INT            NULL,
    [Prog_Id]      INT            NULL,
    [Step]         NVARCHAR (50)  NULL,
    [Doc_Name]     NVARCHAR (500) NULL,
    [Requested_By] NVARCHAR (10)  NULL,
    [Requested_On] DATETIME       NULL,
    [Status]       NVARCHAR (50)  NULL,
    [Style]        NVARCHAR (50)  NULL,
    CONSTRAINT [PK_OXO_Export_Queue] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE TRIGGER [Tri_Export_Queue_Update]
ON [OXO_Export_Queue]
FOR UPDATE
/* Fire this trigger when a row is INSERTED */

AS BEGIN

  SET NOCOUNT ON;
  
  IF UPDATE (Status) 
  BEGIN
  
	  INSERT INTO OXO_Export_Status_History (Request_Id, Status, Status_Date) 
	  SELECT I.Id, I.Status, GETDATE() 
	  FROM INSERTED I;

  END
       
    
END
GO
CREATE TRIGGER [Tri_Export_Queue_Insert]
ON [OXO_Export_Queue]
FOR INSERT
/* Fire this trigger when a row is INSERTED */

AS BEGIN

  SET NOCOUNT ON;
       
  INSERT INTO OXO_Export_Status_History (Request_Id, Status, Status_Date) 
  SELECT I.Id, I.Status, GETDATE() 
  FROM INSERTED I;
  
  
END
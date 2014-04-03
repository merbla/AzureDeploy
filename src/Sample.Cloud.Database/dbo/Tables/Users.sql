CREATE TABLE [dbo].[Users] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [UserName]      NVARCHAR (MAX)   NULL,
    [OpenID]        NVARCHAR (MAX)   NULL,
    [LastLogin]     DATETIME         NOT NULL,
    [CreatedOn]     DATETIME         NOT NULL,
    [ModifiedOn]    DATETIME         NOT NULL,
    [Friendly]      NVARCHAR (MAX)   NULL,
    [ModelId]       UNIQUEIDENTIFIER NOT NULL,
    [Created]       DATETIME         NOT NULL,
    [LastModified]  DATETIME         NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy] NVARCHAR (MAX)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


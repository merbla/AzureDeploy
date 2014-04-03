CREATE TABLE [dbo].[Teams] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX)   NULL,
    [NickName]      NVARCHAR (MAX)   NULL,
    [Image]         NVARCHAR (MAX)   NULL,
    [WebSiteUrl]    NVARCHAR (MAX)   NULL,
    [ModelId]       UNIQUEIDENTIFIER NOT NULL,
    [Created]       DATETIME         NOT NULL,
    [LastModified]  DATETIME         NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy] NVARCHAR (MAX)   NULL,
    [League_Id]     INT              NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [League_Teams] FOREIGN KEY ([League_Id]) REFERENCES [dbo].[Leagues] ([Id])
);


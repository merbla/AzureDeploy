CREATE TABLE [dbo].[Seasons] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX)   NULL,
    [ModelId]       UNIQUEIDENTIFIER NOT NULL,
    [Created]       DATETIME         NOT NULL,
    [LastModified]  DATETIME         NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy] NVARCHAR (MAX)   NULL,
    [League_Id]     INT              NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Season_League] FOREIGN KEY ([League_Id]) REFERENCES [dbo].[Leagues] ([Id])
);


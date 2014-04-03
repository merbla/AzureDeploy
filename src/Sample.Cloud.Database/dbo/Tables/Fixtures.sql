CREATE TABLE [dbo].[Fixtures] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [ModelId]       UNIQUEIDENTIFIER NOT NULL,
    [Created]       DATETIME         NOT NULL,
    [LastModified]  DATETIME         NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy] NVARCHAR (MAX)   NULL,
    [Season_Id]     INT              NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Season_Fixtures] FOREIGN KEY ([Season_Id]) REFERENCES [dbo].[Seasons] ([Id])
);


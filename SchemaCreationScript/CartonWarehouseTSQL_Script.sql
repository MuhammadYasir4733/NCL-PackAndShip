
USE [ActiveSooperWizerNCL];
GO

CREATE SCHEMA [Packing];
GO

CREATE TABLE [Essentials].[Location] (
[LocationID]       INT           IDENTITY (1, 1) NOT NULL,
[Description]      VARCHAR (100) NULL,
[Capacity]         INT           NULL,
[CurrentOccupancy] INT           NULL,
[CreatedBy]        INT           NULL,
[UpdatedBy]        INT           NULL,
[CreatedAt]        DATETIME      DEFAULT (getdate()) NULL,
[UpdatedAt]        DATETIME      DEFAULT (getdate()) NULL,
CONSTRAINT [PK_Location_LocationID] PRIMARY KEY CLUSTERED ([LocationID] ASC)
);


CREATE TABLE [Essentials].[SubLocation] (
[SubLocationID] INT           IDENTITY (1, 1) NOT NULL,
[Name]          VARCHAR (100) NULL,
[LocationID]    INT           NOT NULL,
[CreatedBy]     INT           NULL,
[UpdatedBy]     INT           NULL,
[CreatedAt]     DATETIME      DEFAULT (getdate()) NULL,
[UpdatedAt]     DATETIME      DEFAULT (getdate()) NULL,
CONSTRAINT [PK_SubLocation_SubLocationID] PRIMARY KEY CLUSTERED ([SubLocationID] ASC),
CONSTRAINT [FK_SubLocation_Location] FOREIGN KEY ([LocationID]) REFERENCES [Essentials].[Location] ([LocationID])
);


CREATE TABLE [Packing].[PODetail] (
[PODetailID]      INT            IDENTITY (1, 1) NOT NULL,
[OrId]            NVARCHAR (50)  NULL,
[PO]              NVARCHAR (50)  NULL,
[StyleID]         NVARCHAR (50)  NULL,
[BuyMonth]        NVARCHAR (50)  NULL,
[ColorCode]            NVARCHAR (50)  NULL,
[ColorDesc]            NVARCHAR (100) NULL,
[ExtraAttributes] NVARCHAR (MAX) NULL,
[CreatedBy]       INT            NULL,
[UpdatedBy]       NCHAR (10)     NULL,
[CreatedAt]       DATETIME       CONSTRAINT [DF_PODetail_CreatedAt] DEFAULT (getdate()) NULL,
[UpdatedAt]       DATETIME       CONSTRAINT [DF_PODetail_UpdatedAt] DEFAULT (getdate()) NULL,
CONSTRAINT [PK__PODetail] PRIMARY KEY CLUSTERED ([PODetailId] ASC),
CONSTRAINT [UQ_PODetail] UNIQUE NONCLUSTERED ([PO] ASC, [ColorCode] ASC, [OrId] ASC)
);
GO

CREATE TABLE [Packing].[ShipDetail] (
[ShipDetailID]  INT            IDENTITY (1, 1) NOT NULL,
[PODetailID]            INT            NULL,
[ExFactoryDate]   DATE           NULL,
[ShipTo]          NVARCHAR (255) NULL,
[TransportMethod] NVARCHAR (100) NULL,
[StoreDetail]     NVARCHAR (255) NULL,
[ShipType]        NVARCHAR (10)  NULL,
[PackingDtl]      NVARCHAR (30)  NULL,
[CreatedBy]       INT            NULL,
[UpdatedBy]       INT            NULL,
[CreatedAt]       DATETIME       CONSTRAINT [DF_ShipDetail_DTL_CreatedAt] DEFAULT (getdate()) NULL,
[UpdatedAt]       DATETIME       CONSTRAINT [DF_ShipDetail_DTL_UpdatedAt] DEFAULT (getdate()) NULL,
CONSTRAINT [PK__ShipDetail] PRIMARY KEY CLUSTERED ([ShipDetailID] ASC),
CONSTRAINT [FK__ShipDetail_PODetail] FOREIGN KEY ([PODetailID]) REFERENCES [Packing].[PODetail] ([PODetailID])
);
GO


CREATE TABLE [Packing].[UpcMappingDetail] (
[UpcMappingDetailID] INT            IDENTITY (1, 1) NOT NULL,
[PODetailID]                 INT            NULL,
[ItemSize]             NVARCHAR (50)  NULL,
[ReceivedQty]          INT            NULL,
[DetailUPC]            NVARCHAR (255) NOT NULL,
[OrderQty]             INT            NULL,
[DescriptionDtl]       NVARCHAR (100) NULL,
[HTS]                  NVARCHAR (100) NULL,
[CreatedBy]            INT            NULL,
[UpdatedBy]            INT            NULL,
[CreatedAt]            DATETIME       DEFAULT (getdate()) NULL,
[UpdatedAt]            DATETIME       DEFAULT (getdate()) NULL,
CONSTRAINT [PK__UpcMappingDetail] PRIMARY KEY CLUSTERED ([UpcMappingDetailID] ASC),
CONSTRAINT [FK__UpcMappingDetail_PODetail] FOREIGN KEY ([PODetailID]) REFERENCES [Packing].[PODetail] ([PODetailID])
);
GO


CREATE TABLE [Packing].[PackAndShipDetail] (
[PackAndShipDetailID]   INT             IDENTITY (1, 1) NOT NULL,
[ShipDetailID]          INT             NULL,
[UpcMappingDetailID]    INT             NULL,
[Kit]                   NVARCHAR (255)  NULL,
[Locked]                BIT             CONSTRAINT [DF__PackAndShipDetail_Locked] DEFAULT ((0)) NULL,
[PackRatio]             INT             NULL,
[PackType]              CHAR (1)        NULL,
[OrderQty]              INT             NULL,
[UDT]                   INT             NULL,
[ODT]                   INT             NULL,
[Ext]                   NVARCHAR (255)  NULL,
[CLength]               DECIMAL (10, 2) NULL,
[CWidth]                DECIMAL (10, 2) NULL,
[CHeight]               DECIMAL (10, 2) NULL,
[CreatedBy]             INT             NULL,
[UpdatedBy]             INT             NULL,
[CreatedAt]             DATETIME        CONSTRAINT [DF__PackAndShipDetail_CreatedAt] DEFAULT (getdate()) NULL,
[UpdatedAt]             DATETIME        CONSTRAINT [DF__PackAndShipDetail_UpdatedAt] DEFAULT (getdate()) NULL,
CONSTRAINT [PK__PackAndShipDetail] PRIMARY KEY CLUSTERED ([PackAndShipDetailID] ASC),
CONSTRAINT [FK__PackAndShipDetail_UpcMappingDetail] FOREIGN KEY ([UpcMappingDetailID]) REFERENCES [Packing].[UpcMappingDetail] ([UpcMappingDetailID]),
CONSTRAINT [FK_PackAndShipDetail_ShipDetail] FOREIGN KEY ([ShipDetailID]) REFERENCES [Packing].[ShipDetail] ([ShipDetailID])
);
GO

CREATE TABLE [Packing].[CartonBluePrint] (
[CartonBluePrintID]   INT             IDENTITY (1, 1) NOT NULL,
[PackAndShipDetailID] INT             NULL,
[Name]                NVARCHAR (255)  NULL,
[Description]         NVARCHAR (MAX)  NULL,
[MaxWeight]           DECIMAL (10, 2) NULL,
[MaxGarmentQty]       INT             NULL,
[PackType]            CHAR (1)        NULL,
[CLength]             DECIMAL (10, 2) NULL,
[CWidth]              DECIMAL (10, 2) NULL,
[CHeight]             DECIMAL (10, 2) NULL,
[MinGarmentQty]       INT             NULL,
[DefaultEntry]        INT             CONSTRAINT [DF_CartonBluePrint_DefaultEntry] DEFAULT ((0)) NULL,
[CreatedBy]           INT             NULL,
[UpdatedBy]           INT             NULL,
[CreatedAt]           DATETIME        CONSTRAINT [DF_CartonBluePrint_CreatedAt] DEFAULT (getdate()) NULL,
[UpdatedAt]           DATETIME        CONSTRAINT [DF_CartonBluePrint_UpdatedAt] DEFAULT (getdate()) NULL,
CONSTRAINT [PK__CartonBluePrint] PRIMARY KEY CLUSTERED ([CartonBluePrintID] ASC),
CONSTRAINT [FK_CartonBluePrint_PackAndShipDetail] FOREIGN KEY ([PackAndShipDetailID]) REFERENCES [Packing].[PackAndShipDetail] ([PackAndShipDetailID])
);
GO

CREATE TABLE [Packing].[BluePrintUpcMapping] (
[BluePrintUpcMappingID] INT      IDENTITY (1, 1) NOT NULL,
[CartonBluePrintID]     INT      NULL,
[UpcMappingDetailID]    INT             NULL,
[MaxQty]                INT      NULL,
[CreatedBy]             INT      NULL,
[UpdatedBy]             INT      NULL,
[CreatedAt]             DATETIME DEFAULT (getdate()) NULL,
[UpdatedAt]             DATETIME DEFAULT (getdate()) NULL,
CONSTRAINT [PK__BluePrintUpcMapping] PRIMARY KEY CLUSTERED ([BluePrintUpcMappingID] ASC),
CONSTRAINT [FK_BluePrintUpcMapping_CartonBluePrint] FOREIGN KEY ([CartonBluePrintID]) REFERENCES [Packing].[CartonBluePrint] ([CartonBluePrintID]),
CONSTRAINT [FK__BluePrintUpcMapping_UpcMappingDetail] FOREIGN KEY ([UpcMappingDetailID]) REFERENCES [Packing].[UpcMappingDetail] ([UpcMappingDetailID])
);
GO


CREATE TABLE [Packing].[PrePackingList] (
[PrePackingListID]   INT           IDENTITY (1, 1) NOT NULL,
[ListName]           VARCHAR (255) NULL,
[ShipDetailID]       INT           NULL,
[CreatedDate]        DATETIME      NULL,
[PlannedPackingDate] DATETIME      NULL,
[PackStatus]         NVARCHAR (50) CONSTRAINT [DF_PrePackingList_PackStatus] DEFAULT ((0)) NULL,
[DefaultEntry]       INT           CONSTRAINT [DF_PrePackingList_DefaultEntry] DEFAULT ((0)) NULL,
[CreatedBy]          INT           NULL,
[UpdatedBy]          INT           NULL,
[CreatedAt]          DATETIME      CONSTRAINT [DF_PrePackingList_CreatedAt] DEFAULT (getdate()) NULL,
[UpdatedAt]          DATETIME      CONSTRAINT [DF_PrePackingList_UpdatedAt] DEFAULT (getdate()) NULL,
CONSTRAINT [PK__PrePackingList] PRIMARY KEY CLUSTERED ([PrePackingListID] ASC),
CONSTRAINT [FK_PrePackingList_ShipDetail] FOREIGN KEY ([ShipDetailID]) REFERENCES [Packing].[ShipDetail] ([ShipDetailID])
);
GO


CREATE TABLE [Packing].[PrePackingDetail] (
[PrePackingDetailID] INT      IDENTITY (1, 1) NOT NULL,
[PrePackingListID]     INT      NOT NULL,
[CartonBluePrintID]  INT      NULL,
[NumCartons]           INT      NULL,
[OrderQty]             INT      NULL,
[PlanQty]              INT      NULL,
[LooseQty]             INT      NULL,
[CreatedBy]            INT      NULL,
[UpdatedBy]            INT      NULL,
[CreatedAt]            DATETIME DEFAULT (getdate()) NULL,
[UpdatedAt]            DATETIME DEFAULT (getdate()) NULL,
CONSTRAINT [PK_PrePackingDetail] PRIMARY KEY CLUSTERED ([PrePackingDetailID] ASC),
CONSTRAINT [FK_PrePackingDetail_CartonBluePrint] FOREIGN KEY ([CartonBluePrintID]) REFERENCES [Packing].[CartonBluePrint] ([CartonBluePrintID]),
CONSTRAINT [FK_PrePackingDetail_PrePackingList] FOREIGN KEY ([PrePackingListID]) REFERENCES [Packing].[PrePackingList] ([PrePackingListID])
);
GO



CREATE TABLE [Packing].[CartonDetail] (
[CartonDetailID]       INT           IDENTITY (1, 1) NOT NULL,
[PrePackingDetailID]    INT           NULL,
[SubLocationID]        INT           NULL,
[CartonSequenceGlobal] NVARCHAR (50) NULL,
[CartonNumberGlobal]   INT           NULL,
[CartonNumber]         INT           NULL,
[CartonSequence]       NVARCHAR (50) NULL,
[AllowedQuantity]      INT           NULL,
[CartonStatus]         NVARCHAR (50) NULL,
[CreatedAt]            DATETIME      CONSTRAINT [DF__CARTON_DT__Times__3DB3258D] DEFAULT (getdate()) NULL,
[UpdatedAt]            DATETIME      NULL,
[CreatedBy]            INT           NULL,
[UpdatedBy]            INT           NULL,
CONSTRAINT [PK__CartonDetail] PRIMARY KEY CLUSTERED ([CartonDetailID] ASC),
CONSTRAINT [FK_CartonDetail_PrePackingDetail] FOREIGN KEY ([PrePackingDetailID]) REFERENCES [Packing].[PrePackingDetail] ([PrePackingDetailID]),
CONSTRAINT [FK_CartonDetail_SubLocation] FOREIGN KEY ([SubLocationID]) REFERENCES [Essentials].[SubLocation] ([SubLocationID])
);
GO

CREATE TABLE [Packing].[CartonContents] (
[CartonContentID] INT            IDENTITY (1, 1) NOT NULL,
[CartonDetailID]        INT            NULL,
[UpcMappingDetailID]    INT             NULL,
[EPC]             NVARCHAR (255) NULL,
[Quantity]        INT            NULL,
[Timestamp]       DATETIME       DEFAULT (getdate()) NULL,
[Remarks]         NVARCHAR (MAX) NULL,
[CreatedBy]       INT            NULL,
[UpdatedBy]       INT            NULL,
[CreatedAt]       DATETIME       DEFAULT (getdate()) NULL,
[UpdatedAt]       DATETIME       DEFAULT (getdate()) NULL,
CONSTRAINT [PK__CartonContents] PRIMARY KEY CLUSTERED ([CartonContentID] ASC),
CONSTRAINT [FK_CartonContents_CartonDetail] FOREIGN KEY ([CartonDetailID]) REFERENCES [Packing].[CartonDetail] ([CartonDetailID]),
CONSTRAINT [FK__CartonContents_UpcMappingDetail] FOREIGN KEY ([UpcMappingDetailID]) REFERENCES [Packing].[UpcMappingDetail] ([UpcMappingDetailID])
);
GO


CREATE TABLE [Packing].[PackJob] (
[PackJobID]     INT            IDENTITY (1, 1) NOT NULL,
[Name]          NVARCHAR (50)  NULL,
[PrePackingListID] INT            NULL,
[JobStatus]     NVARCHAR (50)  NULL,
[PlanTime]      DATETIME       NULL,
[TimeSpent]     INT            NULL,
[StartTime]     INT            NULL,
[FinishTime]    DATETIME       NULL,
[Remarks]       NVARCHAR (MAX) NULL,
[CreatedBy]     INT            NULL,
[UpdatedBy]     INT            NULL,
[CreatedAt]     DATETIME       CONSTRAINT [DF_PackJob_CreatedAt] DEFAULT (getdate()) NULL,
[UpdatedAt]     DATETIME       CONSTRAINT [DF_PackJob_UpdatedAt] DEFAULT (getdate()) NULL,
CONSTRAINT [PK_PackJob] PRIMARY KEY CLUSTERED ([PackJobID] ASC),
CONSTRAINT [FK_PackJob_PrePackingList] FOREIGN KEY ([PrePackingListID]) REFERENCES [Packing].[PrePackingList] ([PrePackingListID])
);
GO

CREATE TABLE [Packing].[PackStations] (
[PackStationID]          INT            IDENTITY (1, 1) NOT NULL,
[Name]        NVARCHAR (100) NULL,
[Description] NVARCHAR (255) NULL,
[Unit]        NVARCHAR (255) NULL,
[Factory]     NVARCHAR (255) NULL,
[CreatedBy]   INT            NULL,
[UpdatedBy]   INT            NULL,
[CreatedAt]   DATETIME       DEFAULT (getdate()) NULL,
[UpdatedAt]   DATETIME       DEFAULT (getdate()) NULL,
CONSTRAINT [PK_PackStations] PRIMARY KEY CLUSTERED ([PackStationID] ASC)
);



CREATE TABLE [Packing].[PackJobDetail] (
[PackJobDetailID] INT      IDENTITY (1, 1) NOT NULL,
[CartonDetailID]        INT      NULL,
[PackJobID]       INT      NULL,
[PackStationID]       INT      NULL,
[CreatedBy]       INT      NULL,
[UpdatedBy]       INT      NULL,
[CreatedAt]       DATETIME DEFAULT (getdate()) NULL,
[UpdatedAt]       DATETIME DEFAULT (getdate()) NULL,
CONSTRAINT [PK_PackJobDetail] PRIMARY KEY CLUSTERED ([PackJobDetailID] ASC),
CONSTRAINT [FK_PackJobDetail_CartonDetail] FOREIGN KEY ([CartonDetailID]) REFERENCES [Packing].[CartonDetail] ([CartonDetailID]),
CONSTRAINT [FK_PackJobDetail_PackJob] FOREIGN KEY ([PackJobID]) REFERENCES [Packing].[PackJob] ([PackJobID]),
CONSTRAINT [FK_PackJobDetail_PackStations] FOREIGN KEY ([PackStationID]) REFERENCES [Packing].[PackStations] ([PackStationID])
);



CREATE TABLE [Packing].[CartonAuditLog] (
[CartonAuditLogID] INT           IDENTITY (1, 1) NOT NULL,
[CartonDetailID]         INT           NULL,
[Status]           VARCHAR (20)  NULL,
[Auditor]          VARCHAR (100) NULL,
[AuditDate]        DATE          NULL,
[CreatedBy]        INT           NULL,
[UpdatedBy]        INT           NULL,
[CreatedAt]        DATETIME      DEFAULT (getdate()) NULL,
[UpdatedAt]        DATETIME      DEFAULT (getdate()) NULL,
CONSTRAINT [PK_AuditLog_CartonAuditLog] PRIMARY KEY CLUSTERED ([CartonAuditLogID] ASC),
CONSTRAINT [FK_AuditLog_CartonDetail] FOREIGN KEY ([CartonDetailID]) REFERENCES [Packing].[CartonDetail] ([CartonDetailID])
);


CREATE TABLE [Packing].[CartonTransferRequest] (
[CartonTransferRequestID] INT           IDENTITY (1, 1) NOT NULL,
[Name]                    VARCHAR (256) NOT NULL,
[Remarks]                 VARCHAR (256) NOT NULL,
[RequestType]             VARCHAR (256) NOT NULL,
[RequestDate]             DATE          NULL,
[CreatedBy]               INT           NULL,
[UpdatedBy]               INT           NULL,
[CreatedAt]               DATETIME      DEFAULT (getdate()) NULL,
[UpdatedAt]               DATETIME      DEFAULT (getdate()) NULL,
CONSTRAINT [PK_CartonTransferRequest_CartonTransferRequest] PRIMARY KEY CLUSTERED ([CartonTransferRequestID] ASC)
);


CREATE TABLE [Packing].[CartonTransferLog] (
[CartonTransferLogID]     INT      IDENTITY (1, 1) NOT NULL,
[CartonTransferRequestID] INT      NOT NULL,
[CartonDetailID]                INT      NULL,
[FromSubLocation]         INT      NULL,
[ToSubLocation]           INT      NULL,
[TransferDate]            DATE     NULL,
[CreatedBy]               INT      NULL,
[UpdatedBy]               INT      NULL,
[CreatedAt]               DATETIME DEFAULT (getdate()) NULL,
[UpdatedAt]               DATETIME DEFAULT (getdate()) NULL,
CONSTRAINT [PK_CartonTransferLog] PRIMARY KEY CLUSTERED ([CartonTransferLogID] ASC),
CONSTRAINT [FK_CartonTransferLog_CartonDetail] FOREIGN KEY ([CartonDetailID]) REFERENCES [Packing].[CartonDetail] ([CartonDetailID]),
CONSTRAINT [FK_CartonTransferLog_CartonTransferRequest] FOREIGN KEY ([CartonTransferRequestID]) REFERENCES [packing].[CartonTransferRequest] ([CartonTransferRequestID]),
CONSTRAINT [FK_CartonTransferLog_FromLocation] FOREIGN KEY ([FromSubLocation]) REFERENCES [Essentials].[SubLocation] ([SubLocationID]),
CONSTRAINT [FK_CartonTransferLog_ToLocation] FOREIGN KEY ([ToSubLocation]) REFERENCES [Essentials].[SubLocation] ([SubLocationID])
);


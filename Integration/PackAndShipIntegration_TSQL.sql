-- [Packing].[PODetail]
INSERT INTO [Packing].[PODetail](OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc,CreatedBy)
SELECT OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc,128 AS CreatedBy 
FROM (
SELECT OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc 
FROM [NCPMS].[dbo].[CutOrdSheetDtl]
GROUP BY OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc
) erp
WHERE NOT EXISTS (
SELECT 1 FROM [Packing].[PODetail] T WHERE T.OrId=erp.OrId AND T.PO=erp.PO AND T.ColorCode=erp.ColorCode 
)
ORDER BY OrId,PO,ColorCode



-- [Packing].[UpcMappingDetail]
INSERT [Packing].[UpcMappingDetail](PODetailID, ItemSize,ReceivedQty, DetailUPC, OrderQty, DescriptionDtl, HTS,CreatedBy)
SELECT PODetailID, ItemSize,ReceivedQty, DetailUPC, OrderQty, DescriptionDtl, HTS,CreatedBy FROM
(
SELECT po.PODetailID,cos.ItemSize,SUM(cos.OrderQty) as ReceivedQty,cos.DetailUPC,SUM(cos.OrderQty) as OrderQty,
MAX(cos.DescriptionDtl) as DescriptionDtl,MAX(cos.HTS) as HTS,128 AS CreatedBy
FROM [NCPMS].[dbo].[CutOrdSheetDtl] AS cos
JOIN [Packing].[PODetail] AS po
ON cos.OrId = po.OrId AND cos.PO = po.PO AND cos.ColorCode = po.ColorCode
GROUP BY po.PODetailID,cos.ItemSize,cos.DetailUPC
) erp
WHERE NOT EXISTS (
SELECT 1 FROM [Packing].[UpcMappingDetail] T WHERE T.PODetailID=erp.PODetailID AND T.ItemSize=erp.ItemSize AND T.DetailUPC=erp.DetailUPC 
)
ORDER BY PODetailID,ItemSize
;

-- [Packing].[ShipDetail]
INSERT INTO [Packing].[ShipDetail](PODetailID,ExFactoryDate,ShipTo,TransportMethod,StoreDetail,ShipType,PackingDtl,CreatedBy )
SELECT PODetailID,ExFactoryDate,ShipTo,TransportMethod,StoreDetail,ShipType,PackingDtl,CreatedBy 
FROM (
SELECT po.PODetailID, cos.ExFactoryDate,cos.ShipTo,cos.TransportMethod,cos.Col2 AS StoreDetail,cos.ShipType,cos.PackingDtl,128 AS CreatedBy
FROM [NCPMS].[dbo].[CutOrdSheetDtl] AS cos
JOIN [Packing].[PODetail] AS po ON cos.OrId = po.OrId AND cos.PO = po.PO AND cos.ColorCode = po.ColorCode
GROUP BY po.PODetailID, cos.ExFactoryDate, cos.ShipTo, cos.TransportMethod, cos.Col2,cos.ShipType,cos.PackingDtl
) erp
WHERE NOT EXISTS (
SELECT 1 FROM [Packing].[ShipDetail] T WHERE 
T.PODetailID=erp.PODetailID AND T.ExFactoryDate=erp.ExFactoryDate AND T.ShipTo=erp.ShipTo AND
T.TransportMethod=erp.TransportMethod AND T.StoreDetail=erp.StoreDetail  AND T.ShipType=erp.ShipType  AND T.PackingDtl=erp.PackingDtl 
)
ORDER BY PODetailID;


-- [[Packing].[PackAndShipDetail]
INSERT INTO [Packing].[PackAndShipDetail](ShipDetailID, UpcMappingDetailID, Kit, Locked, PackRatio, PackType, OrderQty, UDT, ODT, Ext, CLength, CWidth, CHeight, CreatedBy)
SELECT ShipDetailID, UpcMappingDetailID, Kit, Locked, PackRatio, PackType, OrderQty, UDT, ODT, Ext, CLength, CWidth, CHeight, CreatedBy
FROM (
SELECT upc.UpcMappingDetailID, shd.ShipDetailID, cos.Kit, 1 AS Locked, cos.PackRatio, cos.PackType, SUM(cos.OrderQty) AS OrderQty,
SUM(cos.UDT) AS UDT, SUM(cos.ODT) AS ODT, 'N/A' AS Ext ,Max(cos.CLength) AS CLength ,Max(cos.CWidth) AS CWidth ,Max(cos.CHeight) AS CHeight,128 AS CreatedBy
FROM [NCPMS].[dbo].[CutOrdSheetDtl] AS cos
JOIN [Packing].[PODetail] AS po ON cos.OrId = po.OrId AND cos.PO = po.PO And cos.ColorCode = po.ColorCode
JOIN [Packing].[UpcMappingDetail] AS upc ON po.PODetailID = upc.PODetailID AND cos.ItemSize = upc.ItemSize AND cos.DetailUPC = upc.DetailUPC 
JOIN [Packing].[ShipDetail] AS shd ON cos.ExFactoryDate = shd.ExFactoryDate AND cos.ShipTo = shd.ShipTo AND cos.TransportMethod = shd.TransportMethod
AND cos.Col2 = shd.StoreDetail AND cos.ShipType = shd.ShipType AND cos.PackingDtl = shd.PackingDtl AND po.PODetailID = shd.PODetailID
GROUP BY upc.UpcMappingDetailID,shd.ShipDetailID,cos.Kit,cos.PackRatio,cos.PackType,cos.ExFactoryDate,cos.ShipTo,
cos.TransportMethod,cos.Col2,cos.ShipType,cos.PackingDtl
) erp
WHERE NOT EXISTS (
SELECT 1 FROM [Packing].[PackAndShipDetail] T WHERE 
T.UpcMappingDetailID=erp.UpcMappingDetailID AND T.ShipDetailID=erp.ShipDetailID AND T.Kit=erp.Kit AND
T.PackRatio=erp.PackRatio  AND T.PackType=erp.PackType  
);




-- ========================================================================================================================================================================
-- ========================================================================================================================================================================



CREATE PROCEDURE [Packing].[uspPackAndShipIntegration](@message VARCHAR(1024) OUT,@code INT OUT)
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY

		BEGIN TRANSACTION

			-- [Packing].[PODetail]
			INSERT INTO [Packing].[PODetail](OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc,CreatedBy)
			SELECT OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc,128 AS CreatedBy 
			FROM (
			SELECT OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc 
			FROM [NCPMS].[dbo].[CutOrdSheetDtl]
			GROUP BY OrId, PO, StyleID, BuyMonth, ColorCode, ColorDesc
			) erp
			WHERE NOT EXISTS (
			SELECT 1 FROM [Packing].[PODetail] T WHERE T.OrId=erp.OrId AND T.PO=erp.PO AND T.ColorCode=erp.ColorCode 
			)
			ORDER BY OrId,PO,ColorCode



			-- [Packing].[UpcMappingDetail]
			INSERT [Packing].[UpcMappingDetail](PODetailID, ItemSize,ReceivedQty, DetailUPC, OrderQty, DescriptionDtl, HTS,CreatedBy)
			SELECT PODetailID, ItemSize,ReceivedQty, DetailUPC, OrderQty, DescriptionDtl, HTS,CreatedBy FROM
			(
			SELECT po.PODetailID,cos.ItemSize,SUM(cos.OrderQty) as ReceivedQty,cos.DetailUPC,SUM(cos.OrderQty) as OrderQty,
			MAX(cos.DescriptionDtl) as DescriptionDtl,MAX(cos.HTS) as HTS,128 AS CreatedBy
			FROM [NCPMS].[dbo].[CutOrdSheetDtl] AS cos
			JOIN [Packing].[PODetail] AS po
			ON cos.OrId = po.OrId AND cos.PO = po.PO AND cos.ColorCode = po.ColorCode
			GROUP BY po.PODetailID,cos.ItemSize,cos.DetailUPC
			) erp
			WHERE NOT EXISTS (
			SELECT 1 FROM [Packing].[UpcMappingDetail] T WHERE T.PODetailID=erp.PODetailID AND T.ItemSize=erp.ItemSize AND T.DetailUPC=erp.DetailUPC 
			)
			ORDER BY PODetailID,ItemSize
			;

			-- [Packing].[ShipDetail]
			INSERT INTO [Packing].[ShipDetail](PODetailID,ExFactoryDate,ShipTo,TransportMethod,StoreDetail,ShipType,PackingDtl,CreatedBy )
			SELECT PODetailID,ExFactoryDate,ShipTo,TransportMethod,StoreDetail,ShipType,PackingDtl,CreatedBy 
			FROM (
			SELECT po.PODetailID, cos.ExFactoryDate,cos.ShipTo,cos.TransportMethod,cos.Col2 AS StoreDetail,cos.ShipType,cos.PackingDtl,128 AS CreatedBy
			FROM [NCPMS].[dbo].[CutOrdSheetDtl] AS cos
			JOIN [Packing].[PODetail] AS po ON cos.OrId = po.OrId AND cos.PO = po.PO AND cos.ColorCode = po.ColorCode
			GROUP BY po.PODetailID, cos.ExFactoryDate, cos.ShipTo, cos.TransportMethod, cos.Col2,cos.ShipType,cos.PackingDtl
			) erp
			WHERE NOT EXISTS (
			SELECT 1 FROM [Packing].[ShipDetail] T WHERE 
			T.PODetailID=erp.PODetailID AND T.ExFactoryDate=erp.ExFactoryDate AND T.ShipTo=erp.ShipTo AND
			T.TransportMethod=erp.TransportMethod AND T.StoreDetail=erp.StoreDetail  AND T.ShipType=erp.ShipType  AND T.PackingDtl=erp.PackingDtl 
			)
			ORDER BY PODetailID;


			-- [[Packing].[PackAndShipDetail]
			INSERT INTO [Packing].[PackAndShipDetail](ShipDetailID, UpcMappingDetailID, Kit, Locked, PackRatio, PackType, OrderQty, UDT, ODT, Ext, CLength, CWidth, CHeight, CreatedBy)
			SELECT ShipDetailID, UpcMappingDetailID, Kit, Locked, PackRatio, PackType, OrderQty, UDT, ODT, Ext, CLength, CWidth, CHeight, CreatedBy
			FROM (
			SELECT upc.UpcMappingDetailID, shd.ShipDetailID, cos.Kit, 1 AS Locked, cos.PackRatio, cos.PackType, SUM(cos.OrderQty) AS OrderQty,
			SUM(cos.UDT) AS UDT, SUM(cos.ODT) AS ODT, 'N/A' AS Ext ,Max(cos.CLength) AS CLength ,Max(cos.CWidth) AS CWidth ,Max(cos.CHeight) AS CHeight,128 AS CreatedBy
			FROM [NCPMS].[dbo].[CutOrdSheetDtl] AS cos
			JOIN [Packing].[PODetail] AS po ON cos.OrId = po.OrId AND cos.PO = po.PO And cos.ColorCode = po.ColorCode
			JOIN [Packing].[UpcMappingDetail] AS upc ON po.PODetailID = upc.PODetailID AND cos.ItemSize = upc.ItemSize AND cos.DetailUPC = upc.DetailUPC 
			JOIN [Packing].[ShipDetail] AS shd ON cos.ExFactoryDate = shd.ExFactoryDate AND cos.ShipTo = shd.ShipTo AND cos.TransportMethod = shd.TransportMethod
			AND cos.Col2 = shd.StoreDetail AND cos.ShipType = shd.ShipType AND cos.PackingDtl = shd.PackingDtl AND po.PODetailID = shd.PODetailID
			GROUP BY upc.UpcMappingDetailID,shd.ShipDetailID,cos.Kit,cos.PackRatio,cos.PackType,cos.ExFactoryDate,cos.ShipTo,
			cos.TransportMethod,cos.Col2,cos.ShipType,cos.PackingDtl
			) erp
			WHERE NOT EXISTS (
			SELECT 1 FROM [Packing].[PackAndShipDetail] T WHERE 
			T.UpcMappingDetailID=erp.UpcMappingDetailID AND T.ShipDetailID=erp.ShipDetailID AND T.Kit=erp.Kit AND
			T.PackRatio=erp.PackRatio  AND T.PackType=erp.PackType  
			);


		COMMIT TRANSACTION

		SET @message = 'Success';
		SET @code = 0;
    
  END TRY
  BEGIN CATCH

		ROLLBACK TRANSACTION;
        SET @message = ERROR_MESSAGE();
	    SET @code = ERROR_NUMBER();
  
  
  END CATCH

END
GO


-- ========================================================================================================================================================================
-- ========================================================================================================================================================================

DECLARE	@message varchar(1024),@code int

EXEC [Packing].[uspPackAndShipIntegration] @message = @message OUTPUT,@code = @code OUTPUT

SELECT	@message as N'Message',@code as N'Code';
GO

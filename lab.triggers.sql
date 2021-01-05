use TSQL2012;

/*Tworzy tabele Logs*/
CREATE TABLE Logs(
	logid INT IDENTITY(1,1),
	date DATETIME,
	tablename NVARCHAR(30),
	operationdetails NVARCHAR(50)
);
GO

/*Trigger na dodawanie w Production.Products*/
CREATE TRIGGER trigInsProductionProducts
ON Production.Products
INSTEAD OF INSERT
AS 
	IF @@ROWCOUNT = 0 RETURN
	SET NOCOUNT ON -- zwiêksza wydajnoœæ, zmniejsza traffic, nie wypisuje obrabiane linie w messages

	BEGIN
		IF NOT EXISTS ((SELECT*FROM Production.Products a, inserted i WHERE a.productname = i.productname))
			BEGIN
				INSERT INTO Logs (date,tablename,operationdetails) VALUES(GETDATE(), 'Production.Products', 'Added successfully')
				INSERT INTO Production.Products(productname,supplierid,categoryid,unitprice,discontinued)
				SELECT productname, supplierid, categoryid, unitprice, discontinued FROM inserted
				PRINT 'Added successfully'
			END
		ELSE
			BEGIN
				PRINT 'Juz istnieje produkt o takiej nazwie'
				INSERT INTO Logs (date,tablename,operationdetails) VALUES(GETDATE(), 'Production.Products', 'Adding crashed')
			END
	END

/*Mo¿na tu sprawdziæ, pierwszy produkt istnieje, drugi - nie*/
INSERT INTO Production.Products(productname,supplierid,categoryid,unitprice,discontinued) VALUES ('Product LUNZZ',2,3,1000,1)
INSERT INTO Production.Products(productname,supplierid,categoryid,unitprice,discontinued) VALUES ('Product ALEXA',2,3,1000,1)
GO

/*Trigger na edytowanie w Production.Products*/
CREATE TRIGGER trigDelProductionProducts
ON Production.Products
INSTEAD OF DELETE
AS 
	IF @@ROWCOUNT = 0 RETURN
	SET NOCOUNT ON -- zwiêksza wydajnoœæ, zmniejsza traffic, nie wypisuje obrabiane linie w messages

	BEGIN
		DECLARE @id INT
		SELECT @id=productid FROM deleted
		IF NOT EXISTS ((SELECT*FROM deleted i, Sales.OrderDetails b
								WHERE i.productid = b.productid))
			BEGIN
				DELETE FROM Production.Products WHERE productid = @id
				PRINT 'Deleted successfully'
				INSERT INTO Logs (date,tablename,operationdetails) VALUES(GETDATE(), 'Production.Products', 'Deleted successfully')
			END
		ELSE
			BEGIN
				PRINT 'Deleting crashed. This product has a reference.'
				INSERT INTO Logs (date,tablename,operationdetails) VALUES(GETDATE(), 'Production.Products', 'Deleting crashed')
			END
	END

/*Pierwszy dodany przez INSERT(brak referencji), drugi jest powi¹zany z inn¹ tablic¹*/
DELETE FROM Production.Products WHERE productname = 'ALEXA UPDATED'
DELETE FROM Production.Products WHERE productname = 'Product LUNZZ'
GO

/*trigger UPDATE*/
CREATE TRIGGER trigUpdProductionProducts
ON Production.Products
INSTEAD OF UPDATE
AS 
	IF @@ROWCOUNT = 0 RETURN
	SET NOCOUNT ON -- zwiêksza wydajnoœæ, zmniejsza traffic, nie wypisuje obrabiane linie w messages

	BEGIN
		IF EXISTS (SELECT * FROM inserted a, deleted b WHERE a.productname <> b.productname OR a.supplierid <> b.supplierid OR a.categoryid <> b.categoryid OR a.unitprice <> b.unitprice OR a.discontinued <> b.discontinued)
			BEGIN
				UPDATE Production.Products
				SET productname = i.productname, supplierid = i.supplierid, categoryid = i.categoryid, unitprice = i.unitprice, discontinued = i.discontinued
				FROM Production.Products a
				INNER JOIN inserted i ON a.productid = i.productid
				PRINT 'Dane zosta³y zaktualizowane pomyœlnie'
				INSERT INTO Logs (date,tablename,operationdetails) VALUES(GETDATE(), 'Production.Products', 'Updated successfully')
			END
		ELSE
			BEGIN
				PRINT 'B³¹d zaktualizowania danych. Nowe i stare dane s¹ identyczne. Proœba wpisaæ inne dane'
				INSERT INTO Logs (date,tablename,operationdetails) VALUES(GETDATE(), 'Production.Products', 'Updating crashed')
			END
	END

/*Pierwsze odnowianie wykona siê na nowym produkcie pomyœlnie, drugie - musi spróbowaæ zmieniæ dane na takie same w 'starym' produkcie,ale wyskoczy b³¹d*/
UPDATE Production.Products SET productname = 'ALEXA UPDATED' WHERE productid = 78
UPDATE Production.Products SET supplierid = 12 WHERE productid = 77
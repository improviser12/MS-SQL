/*1. Utworzyć procedurę CustomersOrdersReport, do generowania raportu zamówień klientów. Parametry:
customer (fragment nazwy firmy klienta companyname), datefrom, dateto wypisującą dane o ilości i wartości zamówień klientów
Gdy parametry mają wartość NULL wszystkie dane są uwzględniane.
Wywołać i przetestować procedurę dla różnych danych

2. Napisać procedurę updateProductsPrice aktualizująca cenę (unitprice) produktów w zależności od liczby zamówionych produktów.
Parametry:
qtyForReduce (od 1 do 10), percentReduced (od 1 do 20), qtyForIncrease (powyżej 20), percentIncreased (od 1 do 20)

3. Napisać procedurę deleteOrder, która usuwa zamówienie o danym id razem ze wszystkim jego szczegółami (z OrderDetails)
Parametry: orderid not null, poscount – maksymalna liczba pozycji zamówienia, dla którego zamówienie może być skasowane, posvalue – maksymalna wartość zamówienia, dla którego zamówienie może być skasowane
gdy poscount (posvalue) null ignorowane sprawdzenie

4. Napisać procedurę dodającą nowy produkt wraz z wszystkim danymi. Obsłużyć szczególne przypadki, zabezpieczając np. przed dodaniem produktu o istniejącej nazwie.
Parametry: productname, categoryname, suppliername, unitprice*/

use TSQL2012;

--свое zad: Przyjmiemy za to, że użytkownik zna nazwę firmy--
/*
IF EXISTS (SELECT * FROM sys.procedures WHERE name= 'ProductAdd' AND type='P')
	DROP PROCEDURE [dbo].[ProductAdd]
GO

Create procedure dbo.ProductAdd
	@productname nvarchar(20) = NULL,
	@categoryname nvarchar(20) = NULL,
	@unitprice money = NULL,
	@suppliername nvarchar(20) = NULL

AS

BEGIN
set nocount on;
	IF NOT EXISTS (SELECT productname, unitprice FROM Production.Products WHERE productname = ISNULL(@productname, productname) AND unitprice = ISNULL(@unitprice, unitprice))
		PRINT 'Brak produktu o takiej cenie'
	ELSE 
		BEGIN
			IF ((SELECT categoryid FROM Production.Categories WHERE categoryname = @categoryname) != 
				(SELECT categoryid FROM Production.Products WHERE productname = @productname))
				PRINT 'Nie istnieje produkt takiej kategorii'
			ELSE IF ((SELECT supplierid FROM Production.Suppliers WHERE companyname = @suppliername) != 
				(SELECT supplierid FROM Production.Products WHERE productname = @productname))
				PRINT 'Produkt nie był dostarczany tą kompanią'
			ELSE
			BEGIN
				SELECT a.productname,
						(SELECT categoryname FROM Production.Categories WHERE categoryname = ISNULL(@categoryname, categoryname)) AS categoryname,
						a.unitprice,
						c.companyname
				FROM Production.Products a, Production.Suppliers c
				WHERE a.productname = ISNULL(@productname, a.productname) AND a.unitprice = ISNULL(@unitprice, a.unitprice) AND c.companyname = ISNULL(@suppliername, c.companyname)
			END;
		END;
END;

EXEC dbo.ProductAdd @productname = 'Product HHYDP', @categoryname = NULL, @unitprice = 10, @suppliername = 'Supplier SWRXU'
*/









--4 zad--

IF EXISTS (SELECT * FROM sys.procedures WHERE name= 'ProductAdd' AND type='P')
	DROP PROCEDURE [dbo].[ProductAdd]
GO

Create procedure dbo.ProductAdd
	@productname nvarchar(20) = NULL,
	@categoryname nvarchar(20) = NULL,
	@unitprice money = NULL,
	@suppliername nvarchar(20) = NULL
AS
set nocount on;
IF EXISTS (SELECT productname FROM Production.Products WHERE @productname = productname)
	PRINT 'Już istnieje produkt o takiej nazwie'
ELSE
	BEGIN
		INSERT INTO Production.Products (productname,supplierid,categoryid, unitprice)
		VALUES (@productname,
				(SELECT supplierid FROM Production.Suppliers WHERE companyname = @suppliername ),
				(SELECT categoryid FROM Production.Categories WHERE categoryname = @categoryname),
				@unitprice)
	END;

EXEC dbo.ProductAdd @productname = 'Product XXXCC', @categoryname = 'Seafood', @unitprice = 123, @suppliername = 'Supplier OGLRK'

--3 zad: discount nie brałem pod uwagę--

IF EXISTS (SELECT * FROM sys.procedures WHERE name= 'deleteOrder' AND type='P')
	DROP PROCEDURE [dbo].[deleteOrder]
GO

CREATE PROCEDURE dbo.deleteOrder
	@orderid int,
	@poscount int = NULL,
	@posvalue money = NULL
AS
set nocount on;
IF NOT EXISTS (SELECT orderid FROM Sales.OrderDetails WHERE orderid = @orderid)
	PRINT 'Nie istnieje zamówienia o takim id lub podany id jest równy zero'
ELSE IF ((SELECT count(orderid) FROM Sales.OrderDetails WHERE orderid = @orderid) > @poscount)
	PRINT 'Liczba takich zamówień jest większa od podanej liczby'
ELSE IF ((SELECT SUM(qty*unitprice) FROM Sales.OrderDetails WHERE orderid = @orderid ) > @posvalue)
	PRINT 'Suma zamówienia jest większa od podanej'
ELSE
	BEGIN
	DELETE FROM Sales.OrderDetails WHERE orderid = @orderid;
	PRINT 'Deleted successfully'
	END

EXEC dbo.deleteOrder @orderid = 10324, @poscount = null, @posvalue = 6200

--2. Napisać procedurę updateProductsPrice aktualizująca cenę (unitprice) produktów w zależności od liczby zamówionych produktów.
--Parametry:
--qtyForReduce (od 1 do 10), percentReduced (od 1 do 20), qtyForIncrease (powyżej 20), percentIncreased (od 1 do 20)

IF EXISTS (SELECT * FROM sys.procedures WHERE name= 'updateProductsPrice' AND type='P')
	DROP PROCEDURE [dbo].[updateProductsPrice]
GO

/*CREATE PROCEDURE dbo.updateProductsPrice
	@qtyForReduce int = 1,
	@percentReduced,
	@qtyForIncrease
	@percentIncreased*/
use TSQL2012

/*1. Napisaæ funkcjê, która zwróci dane zamówieñ klientów o wartoœci od @from do @to*/
IF EXISTS (SELECT * FROM sys.objects WHERE name= 'OrdersFromTO' AND type='IF')
	DROP FUNCTION [dbo].[OrdersFromTo]
GO


CREATE FUNCTION OrdersFromTo (
    @from INT = 0,
	@to INT = 0
)
RETURNS TABLE
AS
RETURN
    SELECT
		oc.custid,
		oc.companyname,
		o.orderid,
		COUNT(*) AS countorders,
		SUM(od.qty * od.unitprice) AS priceorders
	FROM Sales.OrderDetails od
		INNER JOIN Sales.Orders o ON od.orderid = o.orderid
		INNER JOIN Sales.Customers oc ON o.custid = oc.custid
	GROUP BY
		oc.companyname, o.orderid, oc.custid
	HAVING
		SUM(od.qty * od.unitprice) >= @from AND SUM(od.qty * od.unitprice) <= @to
;
GO

select * from dbo.OrdersFromTo(0,100) ORDER BY custid
select companyname, SUM(countorders) as liczbazam, SUM(priceorders) as sumazam from dbo.OrdersFromTo(0,100) GROUP BY companyname ORDER BY companyname

/*Comentarz. Funkcja zwraca companyname oraz liczbê zamówieñ, numer zamówienia, wartoœci sumy zamówiemia których jest w podanym przez u¿ytkownika zakresie*/


/*2. Wykorzystuj¹c funkcjê z punktu 1 ustaliæ w jakim zakresie wartoœci (analizowaæ przedzia³y o szerokoœci 100) jest najwiêksza liczba zamówieñ. Zrobiæ podobne zestawienie dla wszystkich klientów.*/
DECLARE @idcomp INT = 1
WHILE @idcomp <= 91
	BEGIN
		DECLARE @from1 INT = 0, @to1 INT = 100, @result INT, @result1 INT = 0, @fromres INT = 0, @tores INT = 100
		WHILE @to1 <= 9000
			BEGIN
				SET @result = (select SUM(countorders) as liczbazam from dbo.OrdersFromTo(@from1,@to1) where custid = @idcomp GROUP BY companyname)
				IF @result > @result1
					BEGIN
						SET @result1 = @result
						SET @fromres = @from1
						SET @tores = @to1
					END

				SET @from1 = @from1 + 100
				SET @to1 = @to1 + 100
			END
		select Sales.Customers.companyname, @result1 as maxzam, @fromres as zakresod, @tores as zakresdo from Sales.Customers where custid = @idcomp
		SET @idcomp = @idcomp + 1
	END


/*3. Napisaæ funkcjê, która dla danego dostawcy @supplierid zwraca informacjê o œredniej liczbie dni (typ decimal(19,2) ), które up³ynê³y od zamówienia (orderdate) do dostawy (shipperdate) dla wszystkich zrealizowanych zamówieñ z danego miesi¹ca @month (np. listopad 2006)*/
IF EXISTS (SELECT * FROM sys.objects WHERE name= 'AmountOfDays' AND type='IF')
	DROP FUNCTION [dbo].[AmountOfDays]
GO

CREATE FUNCTION AmountOfDays (
    @supplierid INT,
	--@days decimal(19,2),
	@monthzr INT,
	@yearzr INT
)
RETURNS TABLE
AS
RETURN
	SELECT
		CAST(DAY(so.shippeddate-so.orderdate) as decimal(19,2)) as dayys
	FROM Sales.Orders so
	--INNER JOIN Sales.Orders so ON so.shipperid = ss.shipperid
	WHERE @supplierid = so.shipperid AND @monthzr = MONTH(so.shippeddate) AND @yearzr = YEAR(so.shippeddate)
	GROUP BY so.shipperid, so.shippeddate, so.orderdate
;
GO

select AVG(dayys) as avgdays from dbo.AmountOfDays(3,8,2007)

/*Comentarz. Próbowa³em zrobiæ w funkcji AVG(CAST(DAY(so.shippeddate-so.orderdate) as decimal(19,2))), ale fukcja 'avg' nie dzia³a³a*/


/*4. Wykorzystuj¹c funkcjê z punktu 3 znaleŸæ dla ka¿dego z dostawców miesi¹c, w którym œredni czas realizacji zamówieñ by³ najd³u¿szy*/
DECLARE @id INT = 1
WHILE @id <= 3
	BEGIN
		DECLARE @month1 INT = 7, @year1 INT = 2006, @czasmax1 decimal(19,2), @czasmax2 decimal(19,2) = 0
		WHILE @month1 <=12 AND @year1 <=2008
			BEGIN
				SET @czasmax1 = (select AVG(dayys) as avgdays from dbo.AmountOfDays(@id,@month1,@year1))
				IF @czasmax2 < @czasmax1
					BEGIN
						SET @czasmax2 = @czasmax1
					END

				IF @month1 = 12
					BEGIN
						SET @year1 = @year1 + 1
					END
				SET @month1 = @month1 + 1
			END
		select companyname, @czasmax2 as avgmax from Sales.Shippers where shipperid = @id
		SET @id = @id + 1
	END
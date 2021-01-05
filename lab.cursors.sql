use TSQL2012;
GO

/*1) Dla wszystkich zamówień, klientów i dostawców wypisać informacje w postaci:
nazwa klienta, nazwa dostawcy, liczba zamówień o wartości > 2000, liczba zamówień o wartości < 1000, 2000>, liczba zamówień o wartości < 1000,
z wykorzystaniem kursora, pętli (tabel tymczasowych) i zapytania.
Porównać efektywność poszczególnych rozwiązań (SQL Profiler)*/

--przez petle z tablica czasowa
CREATE TABLE curs_czas(
	id INT IDENTITY,
	clientname NVARCHAR(30) NOT NULL,
	shippername NVARCHAR(30) NOT NULL,
	sum DECIMAL(19,2),
	sumL1 BIT,
	sumM1L2 BIT,
	sumM2 BIT
);

INSERT INTO curs_czas(clientname, shippername, sum)
SELECT a.companyname, b.companyname, SUM(d.qty * d.unitprice) FROM Sales.Customers a
INNER JOIN Sales.Orders c ON c.custid = a.custid
INNER JOIN Sales.Shippers b ON b.shipperid = c.shipperid
INNER JOIN Sales.OrderDetails d ON d.orderid = c.orderid
WHERE a.companyname is not null
GROUP BY a.companyname, b.companyname

DECLARE @sum DECIMAL(19,2),@sumL1 BIT, @sumM1L2 BIT, @sumM2 BIT, @i INT = 1
WHILE @i-1 <>(select count(*) from curs_czas)
	BEGIN
		IF ((select sum from curs_czas where id = @i)<1000)
			BEGIN
				UPDATE curs_czas SET sumL1 = 1, sumM1L2 = 0, sumM2 = 0 WHERE id = @i
			END
		IF ((select sum from curs_czas where id = @i)>1000 AND (select sum from curs_czas where id = @i)<2000)
			BEGIN
				UPDATE curs_czas SET sumL1 = 0, sumM1L2 = 1, sumM2 = 0 WHERE id = @i
			END
		IF ((select sum from curs_czas where id = @i)>2000)
			BEGIN
				UPDATE curs_czas SET sumL1 = 0, sumM1L2 = 0, sumM2 = 1 WHERE id = @i
			END
		SET @i =@i+1
	END
SELECT clientname, shippername, sumL1, sumM1L2, sumM2 FROM curs_czas
DROP TABLE curs_czas
--SQL PROFILER. DURATION: 163
--Efektywniej kozystac z petli z talica, niz z kursora
--------------------------------------------------------------------------------------------------------------
--przez kursor
DECLARE @nazwaKlienta NVARCHAR(30), @nazwaDostawcy NVARCHAR(30), @ZAMOWIENIA DECIMAL(19,2)

DECLARE cursZamow CURSOR FOR
SELECT c.companyname, s.companyname, SUM(od.unitprice*od.qty) FROM Sales.Orders o
INNER JOIN Sales.OrderDetails od ON od.orderid = o.orderid
INNER JOIN Sales.Customers c ON o.custid = c.custid
INNER JOIN Sales.Shippers s ON o.shipperid = s.shipperid
GROUP BY c.companyname, s.companyname

PRINT 'Informacja o zamowieniach: '
SET NOCOUNT ON

OPEN cursZamow

FETCH NEXT FROM cursZamow INTO @nazwaKlienta, @nazwaDostawcy, @ZAMOWIENIA
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@ZAMOWIENIA < 1000)
			BEGIN
				PRINT 'Klient: ' + @nazwaKlienta +', dostawca: ' + @nazwaDostawcy + ', zamowienie: (mniej 1000) = ' + cast(@ZAMOWIENIA AS VARCHAR)
			END
		ELSE IF (@ZAMOWIENIA > 1000 AND @ZAMOWIENIA < 2000)
			BEGIN
				PRINT 'Klient: ' + @nazwaKlienta +', dostawca: ' + @nazwaDostawcy + ', zamowienie: (wiecej 1000 i mniej 2000) = ' + cast(@ZAMOWIENIA AS VARCHAR)
			END
		ELSE IF (@ZAMOWIENIA > 2000)
			BEGIN
				PRINT 'Klient: ' + @nazwaKlienta +', dostawca: ' + @nazwaDostawcy + ', zamowienie: (wiecej 2000) = ' + cast(@ZAMOWIENIA AS VARCHAR)
			END

		FETCH NEXT FROM cursZamow INTO @nazwaKlienta, @nazwaDostawcy,  @ZAMOWIENIA
	END
CLOSE cursZamow
DEALLOCATE cursZamow
--SQL PROFILER. DURATION: 178
----------------------------------------------------------------------------------------------------------------------------------------------------------------
/*2) Utworzyć tabelę SupplierTotalizer z danymi supplierid, totalvalue, ordercount oraz SupplierProductsTotalizer z danymi
supplierid, productid, totalvalue, ordercount
i wypełnić ją danymi (dodawanie nowych rekordów lub aktualizacja istniejących) z wykorzystaniem kursora,
pętli (tabel tymczasowych). Każdorazowo wypisywać informacje o dodanych rekordach lub zaktualizowanych.
Dodawać też wpisy do tabeli Logs. Porównać efektywność poszczególnych rozwiązań (SQL Profiler).*/
--przez kursor
CREATE TABLE SupplierTotalizerCzas(
	supplierid INT,
	productid INT,
	totalvalue DECIMAL(19,2),
	ordercount INT
);

CREATE TABLE SupplierTotalizer(
	supplierid INT,
	productid INT,
	totalvalue DECIMAL(19,2),
	ordercount INT
);

DECLARE @supid INT, @prodid INT, @total DECIMAL(19,2), @sumqty INT
DECLARE cursTotalizer CURSOR FOR
SELECT ps.supplierid, pp.productid, SUM(od.qty*od.unitprice), SUM(od.qty) FROM Sales.OrderDetails od
INNER JOIN Production.Products pp ON pp.productid = od.productid
INNER JOIN Production.Suppliers ps ON ps.supplierid = pp.supplierid
GROUP BY ps.supplierid, pp.productid
ORDER BY ps.supplierid

PRINT 'SupplierTotalizer: '
SET NOCOUNT ON

OPEN cursTotalizer

FETCH NEXT FROM cursTotalizer INTO @supid, @prodid, @total, @sumqty
WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO SupplierTotalizerCzas(supplierid, productid, totalvalue, ordercount)
		SELECT ps.supplierid, pp.productid, SUM(od.qty*od.unitprice), SUM(od.qty) FROM Sales.OrderDetails od, Production.Products pp, Production.Suppliers ps
		WHERE pp.productid = od.productid AND ps.supplierid = pp.supplierid
		GROUP BY ps.supplierid, pp.productid
		ORDER BY ps.supplierid

		FETCH NEXT FROM cursTotalizer INTO @supid, @prodid, @total, @sumqty
	END
CLOSE cursTotalizer
DEALLOCATE cursTotalizer
INSERT INTO SupplierTotalizer(supplierid, productid, totalvalue, ordercount)
SELECT supplierid, productid, totalvalue, ordercount FROM SupplierTotalizerCzas GROUP BY supplierid, productid, totalvalue, ordercount ORDER BY supplierid
SELECT*FROM SupplierTotalizer ORDER BY supplierid
DROP TABLE SupplierTotalizerCzas
DROP TABLE SupplierTotalizer
--SQL PROFILER. DURATION: 374
--------------------------------------------------------------------------------------------------------------------------
--przez petle
CREATE TABLE SupplierTotalizerCzasow(
	supplierid INT,
	productid INT,
	totalvalue DECIMAL(19,2),
	ordercount INT
);

DECLARE @a INT = 0, @supplierid INT, @productid INT, @totalvalue DECIMAL(19,2), @ordercount INT, @countrow INT

WHILE @a < 1000
	BEGIN
		INSERT INTO SupplierTotalizerCzasow(supplierid, productid, totalvalue, ordercount)
		SELECT ps.supplierid, pp.productid, SUM(od.qty*od.unitprice), SUM(od.qty) FROM Sales.OrderDetails od
		INNER JOIN Production.Products pp ON pp.productid = od.productid
		INNER JOIN Production.Suppliers ps ON ps.supplierid = pp.supplierid
		GROUP BY ps.supplierid, pp.productid
		ORDER BY ps.supplierid
		OFFSET @a ROWS
		FETCH NEXT 1 ROW ONLY;

		--znajac ilosc supplier zrobi takie sprawdzeie, aby nie wpisywalo puste linie
		IF ((SELECT supplierid FROM SupplierTotalizerCzasow ORDER BY supplierid OFFSET @a ROWS FETCH NEXT 1 ROW ONLY) IS NULL)
			BEGIN
				DELETE FROM SupplierTotalizerCzasow WHERE supplierid IS NULL
				BREAK;
			END
		ELSE
			BEGIN
				SET @a = @a + 1
			END
	END
SELECT*FROM SupplierTotalizerCzasow
DROP TABLE SupplierTotalizerCzasow
--SQL PROFILER. DURATION: 172
--Efektywniej kozystac z petli z talica, niz z kursora
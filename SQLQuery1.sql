/*Zrobi� zestawienie:
1. Kategorie produktu, liczba zestawie�
2. Znale�� nazwy 3 produkt�w, zamawianych najcz�ciej w 2007. 
3. Dla tych produkt�w zrobi� update'a, podnie�� cen� o 10%
4. Usun�� wszystkie produkty, kt�re nie by�y zam�wione. Je�li nie ma takiego produktu, to doda� jaki� insertem*/

/*1*/
select c.categoryname, count(od.orderid) as 'liczbazam�wie�'
from Production.Categories c, Production.Products p, sales.OrderDetails od
where c.categoryid=p.categoryid AND p.productid = od.productid
group by c.categoryname;
 
/*2*/
select TOP 3 c.productname, c.unitprice
from Sales.Orders a, Sales.OrderDetails b, Production.Products c
where c.productid = b.productid AND a.orderid = b.orderid AND '2007-01-01 00:00:00.000'< a.orderdate AND a.orderdate < '2008-01-01 00:00:00.000'
group by c.productname, c.unitprice
order by count(b.orderid) DESC;

/*3*/
select Production.Products.productname, Production.Products.unitprice
from Production.Products
where productname = 'Product VKCMF' OR productname = 'Product UKXRI' OR productname = 'Product XWOXC'
update Production.Products
set unitprice = unitprice + (unitprice * 0.1)
where productname = 'Product VKCMF' OR productname = 'Product UKXRI' OR productname = 'Product XWOXC';
select Production.Products.productname, Production.Products.unitprice
from Production.Products; 
--ostatnie 2 linijki dla por�wnania z nowymi danymi

/*4*/
select b.productid
from Production.Products a, Sales.OrderDetails b
where a.productid = b.productid
group by b.productid
order by b.productid;
--sprawdzi�em, czy zamawiali wszystkie produkty
INSERT INTO Production.Products
VALUES ('Product mojProdukt', 13, 2, 50, 1);
--wstawi�em zamawiany produkt

SELECT t1.productid
FROM Production.Products t1
LEFT JOIN Sales.OrderDetails t2 ON t2.productid = t1.productid
WHERE t2.productid IS NULL
--znalaz�em produkt (innym sposobem), kt�ry nie by� zamawiany nigdy (czyli m�j dodany)
DELETE a FROM Production.Products a
LEFT JOIN Sales.OrderDetails b ON b.productid = a.productid
WHERE b.productid IS NULL;
--usuni�cie produktu, kt�ry nie by� nigdy zam�wiony
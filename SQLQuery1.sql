/*Zrobiæ zestawienie:
1. Kategorie produktu, liczba zestawieñ
2. ZnaleŸæ nazwy 3 produktów, zamawianych najczêœciej w 2007. 
3. Dla tych produktów zrobiæ update'a, podnieœæ cenê o 10%
4. Usun¹æ wszystkie produkty, które nie by³y zamówione. Jeœli nie ma takiego produktu, to dodaæ jakiœ insertem*/

/*1*/
select c.categoryname, count(od.orderid) as 'liczbazamówieñ'
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
--ostatnie 2 linijki dla porównania z nowymi danymi

/*4*/
select b.productid
from Production.Products a, Sales.OrderDetails b
where a.productid = b.productid
group by b.productid
order by b.productid;
--sprawdzi³em, czy zamawiali wszystkie produkty
INSERT INTO Production.Products
VALUES ('Product mojProdukt', 13, 2, 50, 1);
--wstawi³em zamawiany produkt

SELECT t1.productid
FROM Production.Products t1
LEFT JOIN Sales.OrderDetails t2 ON t2.productid = t1.productid
WHERE t2.productid IS NULL
--znalaz³em produkt (innym sposobem), który nie by³ zamawiany nigdy (czyli mój dodany)
DELETE a FROM Production.Products a
LEFT JOIN Sales.OrderDetails b ON b.productid = a.productid
WHERE b.productid IS NULL;
--usuniêcie produktu, który nie by³ nigdy zamówiony
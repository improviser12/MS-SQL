/*
1) Dla wszystkich zam�wie� i klient�w wypisa� informacje w postaci:
nazwa klienta, liczba zam�wie� o warto�ci > 2000, liczba zam�wie� o warto�ci <1000, 2000>, liczba zam�wie� o warto�ci < 1000
2) Dla ka�dego z mened�er�w ustali� ilu ka�dy ma bezpo�rednich i wszystkich podw�adnych
3) Zrobi� totalizer zam�wie� utworzy� tabel� CustomerTotalizer z danymi customerid, totalvalue, ordercount i wype�ni� j� danymi
4) Znale�� ostatni numer zam�wienia (i dat� jego realizacji), dla kt�rego suma warto�ci zam�wie� < 500000
5) Utworzyc widok zawieraj�cy dla ka�dego z dostawc�w liczb� produkt�w zam�wionych w poszczeg�lnych latach
*/

--1 zad--

select b.companyname, SUM(c.qty*c.unitprice)  AS 'Liczbazam�wie�'
from Sales.Orders a, Sales.Customers b, Sales.OrderDetails c
where b.custid = a.custid AND a.orderid = c.orderid
group by b.companyname
order by SUM(c.qty*c.unitprice) DESC;

--2 zad: Zrobiona tylko kolumna, ile ka�dy ma bezpo�rednich podw�adnych --

select mgrid as 'empid', count(mgrid) as 'liczbaBezpo�rednich'
from HR.Employees a
where mgrid is not null
group by mgrid;

--3 zad--

Create Table CustomerTotalizer
(
	customerid INT NOT Null Primary key, --id customers--
	totalvalue Money Default null, --suma pieni�dze za wszystkie zam�wienia--
	ordercount INT Default null --liczba zam�wie�
)

Insert into CustomerTotalizer (customerid, totalvalue, ordercount)
select b.custid, SUM(c.qty*c.unitprice), count(c.orderid)
from Sales.Orders a, Sales.Customers b, Sales.OrderDetails c
where b.custid = a.custid AND a.orderid = c.orderid
group by b.custid;

--4 zad--

select TOP 1 a.orderid, a.orderdate
from Sales.Orders a, Sales.Customers b, Sales.OrderDetails c
where b.custid = a.custid AND a.orderid = c.orderid
group by a.orderid, a.orderdate
Having SUM(c.qty*c.unitprice) < 50000
order by a.orderid DESC;

--5 zad--

select c.companyname, sum(a.qty) as 'liczbazam', year(b.orderdate) as 'za rok'
from Sales.OrderDetails a, Sales.Orders b, Sales.Customers c
where a.orderid = b.orderid AND c.custid = b.custid
group by c.companyname, year(b.orderdate)
order by c.companyname, year(b.orderdate)


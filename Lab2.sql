/*
1) Dla wszystkich zamówieñ i klientów wypisaæ informacje w postaci:
nazwa klienta, liczba zamówieñ o wartoœci > 2000, liczba zamówieñ o wartoœci <1000, 2000>, liczba zamówieñ o wartoœci < 1000
2) Dla ka¿dego z mened¿erów ustaliæ ilu ka¿dy ma bezpoœrednich i wszystkich podw³adnych
3) Zrobiæ totalizer zamówieñ utworzyæ tabelê CustomerTotalizer z danymi customerid, totalvalue, ordercount i wype³niæ j¹ danymi
4) ZnaleŸæ ostatni numer zamówienia (i datê jego realizacji), dla którego suma wartoœci zamówieñ < 500000
5) Utworzyc widok zawieraj¹cy dla ka¿dego z dostawców liczbê produktów zamówionych w poszczególnych latach
*/

--1 zad--

select b.companyname, SUM(c.qty*c.unitprice)  AS 'Liczbazamówieñ'
from Sales.Orders a, Sales.Customers b, Sales.OrderDetails c
where b.custid = a.custid AND a.orderid = c.orderid
group by b.companyname
order by SUM(c.qty*c.unitprice) DESC;

--2 zad: Zrobiona tylko kolumna, ile ka¿dy ma bezpoœrednich podw³adnych --

select mgrid as 'empid', count(mgrid) as 'liczbaBezpoœrednich'
from HR.Employees a
where mgrid is not null
group by mgrid;

--3 zad--

Create Table CustomerTotalizer
(
	customerid INT NOT Null Primary key, --id customers--
	totalvalue Money Default null, --suma pieni¹dze za wszystkie zamówienia--
	ordercount INT Default null --liczba zamówieñ
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


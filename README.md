# Oracle10g-with-SQL-Developer
Oracle10g with SQL Developer - PL/SQL

Introduction
PL/SQL program file that includes parameter passing AND a test script file. 

Database Design
The names of the relations (tables) are: 

CUSTOMERS    ( CustID, Cname, Credit )
SALESPERSONS ( EmpID, Ename, Rank, Salary )
ORDERS       ( OrderID, EmpID, CustID, SalesDate )
ORDERITEMS   ( OrderID, Detail, PartID, Qty )
INVENTORY    ( PartID, Description, StockQty, ReorderPnt, Price )
A PL/SQL program processes a transaction that includes multiple updates to the SalesDB database. Uses COMMIT and ROLLBACK in appropriate logic and handle EXCEPTIONs. Every EXCEPTION handler includes a "WHEN OTHERS THEN" in addition to any other user-defined or system exception that are used for specific catches (such as NO_DATA_FOUND or when INVENTORY could fall below zero for the ordered part).
 
The transaction logic will add (INSERT) a new line item to an already existing order. The scenario could be that a customer has previously placed an order and now wishes to add another item to the order. This could happen by a phone call or a web connection. The input data for this transaction will be the CustID the OrderID, the PartID and quantity for the new line item (in that order). After the new line item (row) has been inserted to the ORDERITEMS table, the INVENTORY table must be updated to reflect the change in StockQty for the PartID on the new line item. After that update, check the value of StockQty. If it is a negative number there is not enough stock to sell so the transaction needs to be rolled back. We can leave a zero balance in stock. Note that we are doing nothing about the ReorderPnt, just checking that StockQty is not less than zero (0).

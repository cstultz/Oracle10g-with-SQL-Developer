/*
********************************************
Oracle10g with SQL Developer
using SQL Developer 4.0.3.16
AddLineItem.sql
2014.11.17 maintenance history
********************************************
*/

-- Lab 7 Assignment 
-- Chris Stultz
-- 2.	Your UPDATE trigger
-- 
-- 2.	The stored procedure (AddLineItem) issues an INSERT command to add a new row 
-- to the ORDERITEMS table. When that INSERT is executed, the INSERT trigger will "fire".  
-- An exception here or from the INSERT trigger means the transaction does not succeed and 
-- neither the INSERT nor the UPDATE will be completed in the database.

--The rest of Inner block 7 from Lab 6
--INSERT statement "fires" INSERT trigger

SET VERIFY OFF
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE AddLineItem                      
    ( iOrderid  IN  ORDERS.Orderid%TYPE,
      iPartid   IN  INVENTORY.Partid%TYPE,
      iQty      IN  ORDERITEMS.Qty%TYPE
    )
AS

    vDetail           ORDERITEMS.Detail%TYPE;     --Holds the next Detail for the Order
    vErrorMessage     VARCHAR2(200);              --Holds the SQLERRM exception error message

    --User defined exception to trap the Stock Qty if it drops below zero
    TooLowStockQty EXCEPTION;
    PRAGMA EXCEPTION_INIT(TooLowStockQty, -20100);

BEGIN

    --Next statement stores OrderItems detail of current Order (if any).
    SELECT MAX(DETAIL)+1 INTO vDetail FROM ORDERITEMS oi JOIN ORDERS o ON oi.Orderid = o.Orderid WHERE oi.OrderID = iOrderid;        

    --Next statement checks to see if there are any OrderItem details on the current order.
    IF vDetail IS NULL THEN
        vDetail := 1; --No OrderItem details on the current order. Set detail to 1.
    END IF;

    --Valid transaction. Insert OrderItem detail for current Order.
    INSERT INTO ORDERITEMS (Orderid, Detail, Partid, Qty)
    VALUES (iOrderid     --Orderid
         ,  vDetail      --Detail
         ,  iPartid      --Partid
         ,  iQty)         --Qty
    ;
    
EXCEPTION --INNER BLOCK #7 (Let the TRANSACTION begin nested program block)
    WHEN TooLowStockQty THEN
        RAISE;
    WHEN NO_DATA_FOUND THEN
        RAISE;
    WHEN OTHERS THEN
        vErrorMessage := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('The ADDLINEITEM inner block of this program encountered the following error: ');
        DBMS_OUTPUT.PUT_LINE (vErrorMessage);
        DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
        RAISE;
END AddLineItem; --INNER BLOCK #7 (Let the TRANSACTION begin nested program block)      
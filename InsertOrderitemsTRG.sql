/*
********************************************
Oracle10g with SQL Developer
using SQL Developer 4.0.3.16
InsertOrderitemsTRG.sql
2014.11.17 maintenance history
********************************************
*/

-- Lab 7 Assignment 
-- Chris Stultz
-- 3.	Update to reduce the quantity on hand (Stockqty) by the amount in the new line item.
-- 
-- 3.	Inside the INSERT trigger (InsertOrderitemsTRG), the value of the new Detail 
-- column will be assigned and an UPDATE will be issued to the INVENTORY table that 
-- reduces the quantity on hand (Stockqty) by the amount in the new line item. This, 
-- in turn will "fire" the UPDATE trigger. An exception here (either from this trigger 
-- directly or by way of the UPDATE trigger) will return to whatever action caused this 
-- trigger to fire.

-- Inner block 8 & 9 from Lab6
-- Then the UPDATE statement "fires" the UPDATE trigger

SET SERVEROUTPUT ON 

CREATE OR REPLACE TRIGGER InsertOrderitemsTRG     
    BEFORE INSERT ON ORDERITEMS
    FOR EACH ROW
 
DECLARE
    vStockQty         INVENTORY.StockQty%TYPE;     --Holds StockQty from INVENTORY projection
    vErrorMessage     VARCHAR2(200);               --Holds the SQLERRM exception error message 

    --User defined exception to trap the Stock Qty if it drops below zero
    TooLowStockQty EXCEPTION;
    PRAGMA EXCEPTION_INIT(TooLowStockQty, -20100);

BEGIN

   --Next statement stores StockQty for current Part ID.
   SELECT STOCKQTY INTO vStockQty FROM INVENTORY i WHERE i.Partid = :new.PartID;

   --Valid transaction. Subtract Ordered Quantity from StockQty of current Part ID.
   UPDATE INVENTORY i
   SET i.StockQty = i.StockQty - :new.Qty
   WHERE i.Partid = :new.PartID;

   --Next statement stores updated StockQty for current Part ID.
     SELECT STOCKQTY INTO vStockQty FROM INVENTORY i WHERE i.Partid = :new.PartID;

   --Output to user to see the before and after update of StockQty value
   DBMS_OUTPUT.PUT_LINE ('Part ID ' || :new.PartID || ' old StockQty was ' || (vStockQty + :new.Qty) || '.');
   DBMS_OUTPUT.PUT_LINE ('Part ID ' || :new.PartID || ' new StockQty is ' || vStockQty || '.');

EXCEPTION 
    WHEN TooLowStockQty THEN
        RAISE;                      --RAISE error back at caller
    WHEN NO_DATA_FOUND THEN
        vErrorMessage := SQLERRM;
        DBMS_OUTPUT.PUT_LINE ('InsertOrderitemsTRG Part ID ' ||:new.Partid || ' ' || 'NOT IN INVENTORY table. StockQty not updated.');
        DBMS_OUTPUT.PUT_LINE (vErrorMessage);
        DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
        RAISE;                      --RAISE error back at caller
    WHEN OTHERS THEN
        vErrorMessage := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('The InsertOrderitemsTRG block of this program encountered the following error: ');
        DBMS_OUTPUT.PUT_LINE (vErrorMessage);
        DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
END InsertOrderitemsTRG;
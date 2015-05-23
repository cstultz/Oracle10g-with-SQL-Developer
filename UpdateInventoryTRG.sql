  /*
********************************************
  Oracle10g with SQL Developer
  using SQL Developer 4.0.3.16
  UpdateInventoryTRG.sql
  2014.11.17 maintenance history
********************************************
*/

-- Lab 7 Assignment 
-- Chris Stultz
-- 4. Check to see if their is enough Stockqty on hand to fill the order. 
--    If not, RAISE an exception which returns all the way back to the 
--    Lab7.sql.

-- The rest of inner block 9 from Lab 6
-- EXCEPTION TooLowStockQty get raised if new StockQty is less than zero

CREATE OR REPLACE TRIGGER UpdateInventoryTRG
BEFORE UPDATE ON INVENTORY
FOR EACH ROW

DECLARE
    
    --Holds the SQLERRM exception error message
    vErrorMessage     VARCHAR2(200);

    --User defined exception to trap the Stock Qty if it drops below zero
    TooLowStockQty EXCEPTION;
    PRAGMA EXCEPTION_INIT(TooLowStockQty, -20100);

BEGIN 
    
    --Check to see if their is enough Stockqty on hand to fill the order.
    IF :new.Stockqty < 0 THEN 
        --RAISE user-defined exception
        raise_application_error(-20100,'There is not enough stock on hand ' || 
                                :old.StockQty || ' to fill the order of ' || (:old.StockQty - :new.StockQty) || '.');
    END IF; 

EXCEPTION
    WHEN TooLowStockQty THEN
        vErrorMessage := SQLERRM;
        DBMS_OUTPUT.PUT_LINE (vErrorMessage);
        DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
        RAISE;                                      --RAISE error back at caller
    WHEN OTHERS THEN
        vErrorMessage := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('The UpdateInventoryTRG block of this program encountered the following error: ');
        DBMS_OUTPUT.PUT_LINE (vErrorMessage);
        DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
END UpdateInventoryTRG;
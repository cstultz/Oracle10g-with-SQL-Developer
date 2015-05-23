/*
********************************************
  Oracle10g with SQL Developer
  using SQL Developer 4.0.3.16
  Lab7.sql
  2014.11.17 maintenance history
********************************************
*/

-- Lab 7 Assignment 
-- Chris Stultz
-- 
-- 1.	The transaction variables (Custid, Orderid, Partid, Qty in that order PLEASE) 
-- will be passed to your program (Lab7.sql) assigned by the subsitution variables 
-- &1, &2, &3, and &4. Your program can use nested or sequential blocks to validate 
-- the Custid, Orderid, Custid/Orderid pairing, Partid, and ensure the quantity is 
-- greater than zero before calling the stored procedure (AddLineItem) where you will 
-- send the Orderid, Partid, and quantity values. When processing returns, the program 
-- is complete.

-- Block 1-6 used from Lab6
-- Then "fire" AddlineItem


SET SERVEROUTPUT ON

DECLARE --OUTER BLOCK #1 (Accept data: CustID, OrderID, PartID, and Quantity substitution variables)

    vCustID                CUSTOMERS.Custid%TYPE  := &1;
    vOrderID               ORDERS.Orderid%TYPE    := &2;
    vPartID                INVENTORY.Partid%TYPE  := &3;
    vQty                   ORDERITEMS.Qty%TYPE    := &4;
    vCustomerValidation    CUSTOMERS.Cname%TYPE;
    vOrderValidation       ORDERS.SalesDate%TYPE;
    vPartValidation        INVENTORY.Description%TYPE;
    vErrorMessage          VARCHAR2(200);  
    vFlag                  CHAR(1) := 'Y';
    vStockQty              INVENTORY.StockQty%TYPE;
    
    --User defined exception to trap the Transaction Failure. Rollback.
    Transaction_Failure    EXCEPTION;

BEGIN --OUTER BLOCK
   
    BEGIN --INNER BLOCK #2 (Verify that the customer exists nested program block)

        --Next statement will throw a NO_DATA_FOUND exception if the CustID entered is invalid.
        SELECT CNAME INTO vCustomerValidation FROM CUSTOMERS WHERE CustID = vCustID; 

    EXCEPTION --INNER BLOCK #2 (Verify that the customer exists nested program block)
        WHEN NO_DATA_FOUND THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE ('Cust ID '||vCustid || ' '||'NOT IN CUSTOMERS table.');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
        WHEN OTHERS THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #2 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
    END; --INNER BLOCK #2 (Verify that the CUSTOMER exists nested program block)
    
    BEGIN --INNER BLOCK #3 (Verify that the ORDER exists nested program block)
      
      --Next statement will throw a NO_DATA_FOUND exception if the OrderID entered is invalid.
      SELECT SALESDATE INTO vOrderValidation FROM ORDERS WHERE OrderID = vOrderID; 

    EXCEPTION --INNER BLOCK #3 (Verify that the ORDER exists nested program block)
        WHEN NO_DATA_FOUND THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE ('Order ID '||vOrderid || ' '||'NOT IN ORDERS table.');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
        WHEN OTHERS THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #3 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
    END; --INNER BLOCK #3 (Verify that the ORDER exists nested program block)      

    DECLARE --INNER BLOCK #4 (Verify that the CUSTOMER has the ORDER nested program block)

      --Next statement will hold the Orders requested that belong to the Customer requested (if any).
      CURSOR c_Cursor IS
          SELECT SALESDATE
          FROM ORDERS o JOIN CUSTOMERS c ON o.Custid = c.Custid
          WHERE o.Orderid = vOrderid AND c.Custid = vCustid;
      vMyRow c_Cursor%ROWTYPE;
      
      Invalid_Order EXCEPTION;
      
    BEGIN --INNER BLOCK #4 (Verify that the CUSTOMER has the ORDER nested program block) 

      OPEN c_Cursor;
      FETCH c_Cursor INTO vMyRow;
      
      --Next statement is to check if the Order requested belongs to the Customer requested. 
      IF c_Cursor%ROWCOUNT = 0 THEN
          RAISE Invalid_Order; --Order requested does not belong to the customer requested. Throw exception.
      END IF;

    EXCEPTION --INNER BLOCK #4 (Verify that the CUSTOMER has the ORDER nested program block)
        WHEN Invalid_Order THEN
            DBMS_OUTPUT.PUT_LINE('Order ID ' || vOrderid || ' does not belong to Cust ID ' || vCustid || '.');
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
        WHEN OTHERS THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #4 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE(vErrorMessage);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
    END; --INNER BLOCK #4 (Verify that the CUSTOMER has the ORDER nested program block)      

    BEGIN --INNER BLOCK #5 (Verify that the Part exists nexted program block)

        --Next statement will throw a NO_DATA_FOUND exception if the CustID entered is invalid.
        SELECT DESCRIPTION INTO vPartValidation FROM INVENTORY WHERE PartID = vPartID; 

    EXCEPTION --INNER BLOCK #5 (Verify that the Part exists nested program block)
        WHEN NO_DATA_FOUND THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE ('Part ID '||vPartid || ' '||'NOT IN INVENTORY table.');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
        WHEN OTHERS THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #5 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
    END; --INNER BLOCK #5 (Verify that the Part exists nested program block)
    
    DECLARE --INNER BLOCK #6 (Verify that the Quantity entered is more than zero nested program black)
    
        Invalid_Quantity    EXCEPTION;
    
    BEGIN --INNER BLOCK #6 (Verify that the Quantity entered is more than zero nested program black)
        
        IF (vQty <= 0) THEN
            RAISE Invalid_Quantity;
        END IF;
        
    EXCEPTION --INNER BLOCK #6 (Verify that the Quantity entered is more than zero nested program black)
        WHEN Invalid_Quantity THEN
            DBMS_OUTPUT.PUT_LINE ('Qty ' || vQty || ' must be greater than zero.');
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
        WHEN OTHERS THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #6 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
    END; --INNER BLOCK #6 (Verify that the Quantity entered is more than zero nested program black)      

    DECLARE --INNER BLOCK #7 (Let the TRANSACTION begin nested program block)

        --User defined exception to trap the Stock Qty if it drops below zero
        TooLowStockQty EXCEPTION;
        PRAGMA EXCEPTION_INIT(TooLowStockQty, -20100);


    BEGIN --INNER BLOCK #7 (Let the TRANSACTION begin nested program block)

        --Next statement creates a SAVEPOINT in order to ROLLBACK to if update to StockQty falls below zero.
        SAVEPOINT sp_NewLineItem_valid;
        
        --Next statement checks to see if we currently still have a valid transaction.
        IF (vFlag = 'Y') THEN
            
            --Call the stored procedure AddLineItem
            AddLineItem (vOrderid, vPartid, vQty); 
            
        END IF;    

    EXCEPTION --INNER BLOCK #7 (Let the TRANSACTION begin nested program block)
        WHEN TooLowStockQty THEN
            vFlag := 'N';
            RAISE Transaction_Failure;
        WHEN NO_DATA_FOUND THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #7 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
            RAISE Transaction_Failure;
        WHEN OTHERS THEN
            vErrorMessage := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('The inner block #7 of this program encountered the following error: ');
            DBMS_OUTPUT.PUT_LINE (vErrorMessage);
            DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE (' ');
            vFlag := 'N';
    END; --INNER BLOCK #7 (Let the TRANSACTION begin nested program block)      

    --Next statement checks to see if we currently still have a valid transaction.
    IF (vFlag = 'Y') THEN
        DBMS_OUTPUT.PUT_LINE ('Successful Transaction. Commit.');
        DBMS_OUTPUT.PUT_LINE ('---------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE ('CustID         Name                       OrderID          Sales Date            PartID         Qty');
        DBMS_OUTPUT.PUT_LINE (rpad(TO_NUMBER(vCustID), 15) || lpad(TO_CHAR(vCustomerValidation), 20) || lpad(TO_NUMBER(vOrderID), 11) || lpad(TO_DATE(vOrderValidation), 22) || lpad(TO_CHAR(vPartValidation), 25) || lpad(TO_NUMBER(vQty), 5));
        DBMS_OUTPUT.PUT_LINE ('---------------------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE (' ');
        COMMIT;
    END IF;

EXCEPTION  --OUTER BLOCK #1 (Accept data: CustID, OrderID, PartID, and Quantity substitution variables)
    WHEN Transaction_Failure THEN --OUTER BLOCK user-defined exception
        
        --Inform end user of Transaction Failure. Rolling back.
        DBMS_OUTPUT.PUT_LINE('Transaction Failure. Rolling back.');
        
        --Next statement rolls back the StockQty update back to the SAVEPOINT
        ROLLBACK;
    WHEN OTHERS THEN
        vErrorMessage := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('The outer block #1 of this program encountered the following error: ');
        DBMS_OUTPUT.PUT_LINE (vErrorMessage);
        DBMS_OUTPUT.PUT_LINE ('SQLCODE: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE (' ');
END; --OUTER BLOCK #1 (Accept data: CustID, OrderID, PartID, and Quantity substitution variables)
CREATE PROC customerRegister
@username varchar(20),@first_name varchar(20), @last_name varchar(20),@password varchar(20),@email varchar(50)
AS 
IF @username IS NULL OR @first_name IS NULL OR @last_name IS NULL OR @password IS NULL OR @email IS NULL 
PRINT 'ONE OF THE INPUTS IS NULL'
ELSE 
INSERT INTO USERS(username,first_name,last_name,password,email)
VALUES(@username,@first_name, @last_name,@password,@email);
INSERT INTO CUSTOMER(USERNAME,POINTS) VALUES(@username,0);

CREATE PROC vendorRegister
@username varchar(20),@first_name varchar(20), @last_name varchar(20),@password varchar(20),@email varchar(50),@company_name varchar(20),@bank_acc_no varchar(20)
AS 
IF @username IS NULL OR @first_name IS NULL OR @last_name IS NULL OR @password IS NULL OR @email IS NULL or @company_name is null or @bank_acc_no is null
PRINT 'ONE OF THE INPUTS IS NULL'
ELSE 
INSERT INTO USERS(username,first_name,last_name,password,email)
VALUES(@username,@first_name, @last_name,@password,@email);
INSERT INTO vendor(USERNAME,company_name,bank_acc_no) VALUES(@username,@company_name,@bank_acc_no);

CREATE PROC userLogin
@username varchar(20), @password varchar(20),@SUCCESS BIT OUTPUT,@TYPE INT OUTPUT
AS
DECLARE @A INT
IF @username IS NULL OR @PASSWORD IS NULL 
PRINT 'ONE OF THE INPUTS IS NULL'
ELSE
IF EXISTS(SELECT * FROM USERS WHERE USERNAME=@USERNAME AND PASSWORD=@PASSWORD)
SET @SUCCESS=1;
IF EXISTS(SELECT * FROM CUSROMER WHERE USERNAME=@USERNAME)
SET @TYPE=0;
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@USERNAME)
SET @TYPE=1;
IF EXISTS(SELECT * FROM ADMINS WHERE USERNAME=@USERNAME)
SET @TYPE=2;
IF EXISTS(SELECT * FROM DELIVERY_PERSON WHERE USERNAME=@USERNAME)
SET @TYPE=3;
ELSE 
SET @SUCCESS=0;
SET @TYPE=NULL;

DROP PROC userLogin
EXEC userLogin 'farahehab','pass233'

CREATE PROC addMobile
@username varchar(20), @mobile_number varchar(20)
AS
IF @username IS NULL OR @MOBILE_NUMBER IS NULL
PRINT 'SORRY THE INPUT IS NULL';
INSERT INTO User_mobile_numbers(USERNAME,MOBILE_NUMBER) VALUES(@USERNAME,@mobile_number);
 
 CREATE PROC addAddress
@username varchar(20), @address varchar(100)
AS
IF @username IS NULL OR @address IS NULL
PRINT 'SORRY THE INPUT IS NULL';
INSERT INTO User_Addresses(USERNAME,ADDRESS) VALUES(@USERNAME,@address);

INSERT INTO PRODUCT(SERIAL_NO,product_name) VALUES(223,'FORSHA ASNAN');

CREATE PROC showProducts
AS
SELECT product_name,product_description,price,final_price,color FROM Product;

CREATE PROC ShowProductsbyPrice
AS
SELECT * FROM Product
ORDER BY final_price;

CREATE PROC searchbyname
@TEXT VARCHAR(20)
AS
SELECT * FROM Product WHERE product_name=@TEXT;

CREATE PROC AddQuestion
@serial int, @customer varchar(20), @Question varchar(50)
AS 
INSERT INTO Customer_Question_Product(serial_no,customer_name,question) VALUES(@serial,@customer,@Question);

CREATE PROC addToCart
@customername varchar(20), @serial int
AS
INSERT INTO CustomerAddstoCartProduct VALUES(@serial,@customername);

CREATE PROC removefromCart
@customername varchar(20), @serial int
AS 
DELETE FROM CustomerAddstoCartProduct WHERE SERIAL_NO=@serial AND CUSTOMER_NAME=@customername;

CREATE PROC createWishlist
@customername varchar(20), @name varchar(20)
AS
INSERT INTO Wishlist VALUES(@customername,@NAME);

CREATE PROC AddtoWishlist
@customername varchar(20), @wishlistname varchar(20), @serial int
AS
INSERT INTO Wishlist_Product VALUES(@customername,@wishlistname,@serial);


CREATE PROC removefromWishlist
@customername varchar(20), @wishlistname varchar(20), @serial int
AS
DELETE FROM Wishlist_Product WHERE USERNAME=@customername AND WISH_NAME=@wishlistname AND SERIAL_NO=@serial;

create proc showWishlistProduct
@customername varchar(20), @name varchar(20)
AS
SELECT P.product_name,P.PRODUCT_DESCRIPTION,p.price,P.FINAL_PRICE,P.COLOR FROM WISHLIST_PRODUCT W 
INNER JOIN PRODUCT P ON W.SERIAL_NO=P.SERIAL_NO
WHERE
W.USERNAME=@CUSTOMERNAME AND W.WISH_NAME=@NAME;

CREATE PROC viewMyCart
@customer varchar(20)
AS
SELECT  P.NAME,P.PRODUCT_DESCRIPTION,p.price,P.FINAL_PRICE,P.COLOR FROM CUSTOMER_ADDSTOCARTPRODUCT C
INNER JOIN PRODUCT P ON C.SERIAL_NO=P.SERIAL_NO
WHERE C.CUSTOMER_NAME=@CUSTOMER;

CREATE PROC calculatepriceOrder
@customername varchar(20), @sum decimal(10,2) OUTPUT
AS
SELECT @SUM=SUM(P.FINAL_PRICE) FROM CUSTOMER_ADDSTOCARTPRODUCT C
INNER JOIN PRODUCT P ON C.SERIAL_NO=P.SERIAL_NO
WHERE C.CUSTOMER_NAME=@CUSTOMERNAME ;

--RUNEET EL PROC DY
CREATE PROC productsinorder
@customername varchar(20), @orderID int
AS
UPDATE PRODUCT  
SET AVAILABLE=0,CUSTOMER_USERNAME=@customername, CUSTOMER_ORDER_ID=@ORDERID WHERE  EXISTS(SELECT * FROM CUSTOMER_ADDSPRODUCT C INNER JOIN PRODUCT P ON C.SERIAL_NO=P.SERIAL_NO WHERE C.CUSTOMER_NAME=@CUSTOMERNAME)AND serial_no=P.serial_no;

DELETE FROM PRODUCT WHERE EXISTS(SELECT * FROM CUSTOMER_ADDSPRODUCT C INNER JOIN PRODUCT P ON C.SERIAL_NO=P.SERIAL_NO WHERE C.CUSTOMER_NAME<>@CUSTOMERNAME);



create proc emptyCart
@customername varchar(20)
as
DELETE CUSTOMER_ADDSTOCARTPRODUCT WHERE CUSTOMER_NAME=@CUSTOMERNAME;



CREATE PROC makeOrder
@customername varchar(20)
AS
DECLARE @AMOUNT DECIMAL(10,2);
EXEC CALCULATEPRICEORDER @CUSTOMERNAME, @AMOUNT
INSERT INTO ORDERS(TOTAL_AMOUNT,ORDER_STATUS,CUSTOMER_NAME,ORDER_DATE) VALUES(@AMOUNT,'NOT PROCESSED',@CUSTOMERNAME,CURRENT_TIMESTAMP);
DECLARE @ID INT;
SELECT MAX(ORDER_NO) FROM ORDERS;
EXEC PRODUCTSINORDER @CUSTOMERNAME,@ID;
EXEC emptyCart @CUSTOMERNAME;

drop proc cancelOrder
CREATE PROC cancelOrder
@orderid int
AS
IF EXISTS(SELECT * FROM ORDERS WHERE order_no=@orderid AND (order_status='NOT PROCESSED' OR order_status='IN PROCESSED')) 
BEGIN
UPDATE PRODUCT  
SET AVAILABLE=1,CUSTOMER_USERNAME=null, CUSTOMER_ORDER_ID=null where customer_order_id=@orderid 
if exists(select * from Giftcard g inner join Admin_Customer_Giftcard a on g.code=a.code inner join Orders o on o.customer_name=a.customer_name  where o.order_no=@orderid and g.code=o.GIFTCARDCODEUSED and (g.expiry_date>CURRENT_TIMESTAMP or g.expiry_date=CURRENT_TIMESTAMP))
begin
update CUSTOMER
set points=points+(o.total_amount-o.cash_amount) from CUSTOMER c inner join Orders o on o.customer_name=c.USERNAME where (o.cash_amount is not null)
update CUSTOMER
set points=points+(o.total_amount-o.credit_amount) from CUSTOMER c inner join Orders o on o.customer_name=c.USERNAME where (o.credit_amount is not null)
update Admin_Customer_Giftcard
set remaining_points=remaining_points+(o.total_amount-o.cash_amount) from Admin_Customer_Giftcard c inner join Orders o on o.customer_name=c.customer_name where (o.cash_amount is not null)
update Admin_Customer_Giftcard
set remaining_points=remaining_points+(o.total_amount-o.credit_amount) from Admin_Customer_Giftcard c inner join Orders o on o.customer_name=c.customer_name where (o.credit_amount is not null)
DELETE FROM ORDERS WHERE order_no=@orderid;
end
END
ELSE
PRINT'ORDER CANNOT BE CANCELED';

CREATE PROC returnProduct
@serialno int, @orderid int
AS
UPDATE PRODUCT 
SET AVAILABLE=1,customer_username=NULL, CUSTOMER_ORDER_ID=NULL,RATE=NULL WHERE  EXISTS(SELECT * FROM CUSTOMER_ADDSPRODUCT C INNER JOIN PRODUCT P ON C.SERIAL_NO=P.serial_no) AND serial_no=P.serial_no;

UPDATE ORDERS
SET TOTAL_AMOUNT=0 WHERE ORDER_NO=@ORDERID;
UPDATE ORDERS
SET CASH_AMOUNT=0 WHERE CASH_AMOUNT=NULL AND ORDER_NO=@ORDERID;
UPDATE ORDERS
SET CREDIT_AMOUNT=0 WHERE CREDIT_AMOUNT=NULL AND ORDER_NO=@ORDERID;


CREATE PROC ShowproductsIbought
@customername varchar(20)
AS
SELECT SERIAL_NO,PRODUCT_NAME,CATEGORY,PRODUCT_DESCRIPTION,PRICE,FINAL_PRICE,COLOR FROM PRODUCT WHERE CUSTOMER_USERNAME=@CUSTOMERNAME;

CREATE PROC rate
@serialno int, @rate int , @customername varchar(20)
AS
UPDATE PRODUCT
SET RATE=@RATE WHERE SERIAL_NO=@serialno AND customer_username=@customername;

CREATE PROC SpecifyAmount
@customername varchar(20), @orderID int, @cash decimal(10,2), @credit decimal(10,2)
AS
UPDATE Orders
SET cash_amount=@cash,credit_amount=@credit WHERE order_no=@orderID;
IF @credit=NULL OR @credit=0
BEGIN
UPDATE CUSTOMER
SET POINTS=C.POINTS-(O.total_amount-O.cash_amount) FROM CUSTOMER C INNER JOIN Orders O ON C.USERNAME=O.customer_name WHERE C.USERNAME=@customername;
UPDATE Admin_Customer_Giftcard
SET remaining_points= remaining_points-(O.total_amount-O.cash_amount) FROM Admin_Customer_Giftcard C1 INNER JOIN ORDERS O ON c1.customer_name=o.customer_name;
UPDATE Orders
SET GIFTCARDCODEUSED=C1.code FROM Admin_Customer_Giftcard C1 INNER JOIN ORDERS ON C1.customer_name=@customername and total_amount<> @cash;
end
UPDATE CUSTOMER
SET POINTS=C.POINTS-(O.total_amount-O.credit_amount) FROM CUSTOMER C INNER JOIN Orders O ON C.USERNAME=O.customer_name WHERE C.USERNAME=@customername;
UPDATE Admin_Customer_Giftcard
SET remaining_points= remaining_points-(O.total_amount-O.cash_amount) FROM Admin_Customer_Giftcard C1 INNER JOIN ORDERS O ON c1.customer_name=o.customer_name;
UPDATE Orders
SET GIFTCARDCODEUSED= C1.code FROM Admin_Customer_Giftcard C1 INNER JOIN ORDERS ON C1.customer_name=@customername;

EXEC SpecifyAmount 'ahmed.sharaf',4,20,0

DROP PROC SpecifyAmount
CREATE PROC AddCreditCard
@creditcardnumber varchar(20), @expirydate date , @cvv varchar(4), @customername varchar(20)
AS
INSERT INTO Credit_Card VALUES(@creditcardnumber,@expirydate,@cvv);
INSERT INTO Customer_CreditCard VALUES(@customername,@creditcardnumber);

--EXEC AddCreditCard '4444-5555-6666-8888','19/10/2028',232,'ahmed.sharaf'

CREATE PROC ChooseCreditCard
@creditcard varchar(20), @orderid int
AS
UPDATE ORDERS
SET creditCard_number=@creditcard WHERE order_no=@orderid;

--EXEC ChooseCreditCard '4444-5555-6666-8888',2

CREATE PROC viewDeliveryTypes
AS
SELECT DISTINCT(TYPE),time_duration,fees FROM Delivery;

DROP PROC viewDeliveryTypes
EXEC viewDeliveryTypes

CREATE PROC specifydeliverytype
@orderID int, @deliveryID int
AS
UPDATE Orders
SET O.delivery_id=@deliveryID
SET O.remaining_days= D.time_duration FROM Orders O INNER JOIN Delivery D ON O.delivery_id=D.id WHERE O.order_no=@orderID;

--FAKARY FEHAAA TRACK REMAINING DAYS
--MSH FAHMAHA AWY

CREATE PROC recommmend
@customername varchar(20)
AS
--SELECT TOP(3) P1.serial_no,P1.product_name,P1.category,P1.product_description,P1.price,P1.final_price,P1.color 
--FROM PRODUCT P1
--INNER JOIN( SELECT SERIAL_NO FROM Wishlist_Product GROUP BY serial_no ORDER BY COUNT(*) DESC) W1 ON P1.serial_no=W1.serial_no 
--INNER JOIN 
--(SELECT TOP(3) P.category
--FROM PRODUCT P INNER JOIN CustomerAddstoCartProduct C ON P.serial_no=C.serial_no  WHERE C.customer_name='MAYA' --@customername
--GROUP BY P.category
--ORDER BY COUNT(*) DESC) CAT1 ON P1.category=CAT1.category 
--WITH TIES WLA WITHOUT??



(SELECT P1.serial_no,P1.product_name,P1.category,P1.product_description,P1.final_price,P1.color 
FROM PRODUCT P1
INNER JOIN
(SELECT TOP(3) W.SERIAL_NO FROM Wishlist_Product W INNER JOIN 
PRODUCT PP ON PP.serial_no=W.serial_no 
INNER JOIN(SELECT TOP(3) P.category
FROM PRODUCT P INNER JOIN CustomerAddstoCartProduct C ON P.serial_no=C.serial_no  WHERE C.customer_name='MAYA' --@customername
GROUP BY P.category
ORDER BY COUNT(*) DESC) CAT ON PP.category=CAT.category
GROUP BY W.serial_no
ORDER BY COUNT(*) DESC) WISH1 ON WISH1.serial_no=P1.serial_no
UNION all
SELECT P1.serial_no,P1.product_name,P1.category,P1.product_description,P1.price,P1.final_price,P1.color 
FROM PRODUCT P1
INNER JOIN
(SELECT TOP(3) W.SERIAL_NO FROM Wishlist_Product W INNER JOIN 
(SELECT customer_name FROM CustomerAddstoCartProduct
WHERE customer_name<>'MAYA' --@CUSTOMERNAME
GROUP BY customer_name) S ON W.username=S.customer_name
GROUP BY W.serial_no
ORDER BY COUNT(*) DESC) R ON P1.serial_no=R.serial_no) 
ORDER BY SERIAL_NO DESC
--FADEL HWAR AVAILABLE DA ABL MA AKHTAR WLA BA3DAHA WLA EH? 

--INSERT INTO Wishlist_Product VALUES('SALMA','OOPAA',2245);

--INSERT INTO CustomerAddstoCartProduct VALUES(2256,'SALMA');
--INSERT INTO Wishlist_Product VALUES('FARAH','OOKAY',2256)
--INSERT INTO Wishlist VALUES('FARAH','OOKAY');
--INSERT INTO PRODUCT(SERIAL_NO,product_name,CATEGORY) VALUES(2256,'SENARA','SED');
--INSERT INTO CustomerAddstoCartProduct VALUES(2256,'MAYA');

EXEC recommmend 'ahmed.sharaf'
CREATE PROC postProduct
@vendorUsername varchar(20), @product_name varchar(20) ,@category varchar(20), @product_description text , @price decimal(10,2), @color varchar(20)
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorUsername AND activated=1)
INSERT INTO PRODUCT(PRODUCT_NAME,category,product_description,price,final_price,color,vendor_username) VALUES(@product_name,@category,@product_description,@price,@price,@color,@vendorUsername)
ELSE PRINT 'SORRY YOU ARE NOT ACTIVATED'; 

CREATE PROC vendorviewProducts
@vendorname varchar(20)
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorUsername AND activated=1)
SELECT * FROM PRODUCT WHERE vendor_username=@vendorname;
ELSE PRINT 'SORRY YOU ARE NOT ACTIVATED';

CREATE PROC EditProduct
@vendorname varchar(20), @serialnumber int, @product_name varchar(20) ,@category varchar(20),
@product_description text , @price decimal(10,2), @color varchar(20)
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorUsername AND activated=1)
BEGIN
UPDATE PRODUCT
SET product_name=@product_name WHERE SERIAL_NO=@serialnumber AND @product_name IS NOT NULL AND vendor_username=@vendorname;
UPDATE PRODUCT
SET category=@category WHERE SERIAL_NO=@serialnumber AND @category IS NOT NULL;
UPDATE PRODUCT
SET product_description=@product_description WHERE SERIAL_NO=@serialnumber AND @product_description IS NOT NULL AND vendor_username=@vendorname;
UPDATE PRODUCT
SET price=@price,final_price=@price WHERE SERIAL_NO=@serialnumber AND @price IS NOT NULL AND vendor_username=@vendorname;
UPDATE PRODUCT
SET COLOR=@color WHERE SERIAL_NO=@serialnumber AND @COLOR IS NOT NULL AND vendor_username=@vendorname;
--FEH HWAR EL FINAL PRICE ELMAFRROD YB2A UPDATED FOR NOW HANKHALEEH EQUAL 3LA MA NSHOOF
END
ELSE 
PRINT 'SORRY YOU ARE NOT ACTIVATED';

CREATE PROC deleteProduct
@vendorname varchar(20), @serialnumber int
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorUsername AND activated=1)
DELETE FROM PRODUCT WHERE serial_no=@serialnumber AND vendor_username=@vendorname;
ELSE
PRINT 'SORRY YOU ARE NOT ACTIVATED';


CREATE PROC viewQuestions
@vendorname varchar(20)
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorUsername AND activated=1) 
SELECT Q.QUESTION FROM Customer_Question_Product Q 
INNER JOIN Product P ON P.serial_no=Q.serial_no
WHERE P.vendor_username=@vendorname;
ELSE 
PRINT 'SORRY YOU ARE NOT ACTIVATED';

CREATE PROC answerQuestions
@vendorname varchar(20), @serialno int, @customername varchar(20), @answer text
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorUsername AND activated=1) AND EXISTS(SELECT * FROM PRODUCT WHERE serial_no=@serialno AND vendor_username=@vendorname)
BEGIN
UPDATE Customer_Question_Product
SET answer=@answer WHERE SERIAL_NO=@serialno AND customer_name=@customername;
END
ELSE 
PRINT 'SORRY YOU ARE NOT ACTIVATED';


CREATE PROC addOffer
@offeramount int, @expiry_date datetime
AS
INSERT INTO offer VALUES(@offeramount,@expiry_date);

CREATE PROC checkOfferonProduct
@serial int,@activeoffer bit OUTPUT
AS
IF EXISTS(SELECT * FROM PRODUCT P INNER JOIN offersOnProduct O ON O.serial_no=P.serial_no)
SET @activeoffer=1;
ELSE 
SET @activeoffer=0;

CREATE PROC checkandremoveExpiredoffer
@offerid int
AS
IF EXISTS(SELECT * FROM offer WHERE offer_id=@offerid AND expiry_date<CURRENT_TIMESTAMP)
UPDATE PRODUCT
SET P.final_price=P.final_price+F.offer_amount FROM PRODUCT P INNER JOIN offersOnProduct O ON P.serial_no=O.serial_no INNER JOIN OFFER F ON F.offer_id=O.offer_id WHERE O.offer_id=@offerid 
DELETE FROM offersOnProduct WHERE offer_id=@offerid 
DELETE FROM OFFER WHERE offer_id=@offerid;


CREATE PROC applyOffer
@vendorname varchar(20), @offerid int, @serial int
AS
IF EXISTS(SELECT * FROM VENDOR WHERE USERNAME=@vendorname AND activated=1)
BEGIN
EXEC checkandremoveExpiredoffer @OFFERID ;
DECLARE @WW BIT
EXEC CHEcheckOfferonProduct @SERIAL,@WW
IF @WW=0
INSERT INTO offersOnProduct VALUES(@offerid,@serial);
UPDATE PRODUCT
SET final_price=final_price-F.offer_amount FROM PRODUCT P INNER JOIN offersOnProduct O ON P.serial_no=O.serial_no INNER JOIN OFFER F ON F.offer_id=O.offer_id WHERE O.offer_id=@offerid AND serial_no=@serial AND vendor_username=@vendorname;
END
ELSE 
PRINT 'SORRY YOU ARE NOT ACTIVATED';



CREATE PROC activateVendor
@admin_username varchar(20),@vendor_username varchar(20)
AS
UPDATE VENDOR 
SET activated=1,admin_username=@admin_username WHERE USERNAME=@vendor_username;




CREATE PROC  inviteDeliveryPerson
@delivery_username varchar(20), @delivery_email varchar(50)
AS
INSERT INTO USERS(USERNAME,email) VALUES(@delivery_username,@delivery_email);
INSERT INTO Delivery_Person VALUES(@delivery_username,0);


CREATE PROC reviewOrders
AS 
SELECT * FROM ORDERS;

EXEC reviewOrders

CREATE PROC updateOrderStatusInProcess
@order_no int
AS
UPDATE ORDERS
SET order_status='In process' WHERE order_no=@order_no;

CREATE PROC addDelivery
@delivery_type varchar(20),@time_duration int,@fees decimal(5,3),@admin_username varchar(20)
AS
INSERT INTO Delivery(DELIVERY_TYPE,time_duration,fees,username) VALUES(@delivery_type,@time_duration,@fees,@admin_username);

CREATE PROC  assignOrdertoDelivery
@delivery_username varchar(20),@order_no int,@admin_username varchar(20)
AS
INSERT INTO Admin_Delivery_Order(delivery_username,order_no,admin_username) VALUES(@delivery_username,@order_no,@admin_username);

CREATE PROC createTodaysDeal
@deal_amount int,@admin_username varchar(20),@expiry_date datetime
AS
INSERT INTO Todays_Deals(deal_amount,admin_username,expiry_date) VALUES(@deal_amount,@admin_username,@expiry_date);


CREATE PROC checkTodaysDealOnProduct
@serial_no INT,@activeDeal BIT OUTPUT
AS
IF EXISTS(SELECT * FROM Todays_Deals_Product WHERE serial_no=@serial_no)
SET @activeDeal=1;
ELSE
SET @activeDeal=0;

CREATE PROC addTodaysDealOnProduct
@deal_id int, @serial_no int
AS
EXEC removeExpiredDeal @DEAL_ID;
DECLARE @S BIT;
EXEC checkTodaysDealOnProduct @SERIAL_NO, @S;
IF @S=0
BEGIN
INSERT INTO Todays_Deals_Product VALUES(@deal_id,@serial_no);
--MSH MAKTOOBA
UPDATE PRODUCT
SET final_price=final_price-T.deal_amount FROM Product P INNER JOIN Todays_Deals_Product T ON P.serial_no=T.serial_no INNER JOIN Todays_Deals D ON D.deal_id=T.deal_id  WHERE P.serial_no=@serial_no AND T.deal_id=@deal_id;
END
--LW FEH DEAL MSH EXPIRED???


CREATE PROC removeExpiredDeal
@deal_iD int
AS
IF EXISTS(SELECT * FROM Todays_Deals WHERE DEAL_id=@deal_iD AND expiry_date<CURRENT_TIMESTAMP)
UPDATE PRODUCT 
SET final_price=final_price+T.deal_amount FROM Product P INNER JOIN Todays_Deals_Product T ON P.serial_no=T.serial_no INNER JOIN Todays_Deals D ON D.deal_id=T.deal_id  WHERE P.serial_no=@serial_no AND T.deal_id=@deal_id;
DELETE FROM Todays_Deals_Product WHERE deal_id=@deal_iD;
DELETE FROM Todays_Deals WHERE deal_iD=@deal_iD

create proc createGiftCard
@code varchar(10),@expiry_date datetime,@amount int,@admin_username varchar(20) 
as
if exists(select code from giftcard where code=@code)
print 'gift card already exsists';
else
insert into GiftCard values(@code,@expiry_date,@amount,@admin_username);



CREATE PROC removeExpiredGiftCard
@code varchar(10)
AS
IF EXISTS(SELECT * FROM Giftcard WHERE code=@code AND expiry_date<CURRENT_TIMESTAMP)
update CUSTOMER
set points=points-g.remaining_points from CUSTOMER c inner join Admin_Customer_Giftcard g on c.USERNAME=g.customer_name where g.code=@code;
DELETE FROM Admin_Customer_Giftcard WHERE code=@code;
DELETE FROM Giftcard WHERE code=@code;



 create proc checkGiftCardOnCustomer
@code varchar(10),@activeGiftCard bit output
as
if exists(select code from giftcard where code=@code)
set @success=1;
else 
set @success=0;



-- NEEDS TO BE FIXED!!
CREATE PROC giveGiftCardtoCustomer
@code varchar(10),@customer_name varchar(20),@admin_username varchar(20)
AS
declare @bb bit;
EXEC checkGiftCardOnCustomer @code, @BB;
IF @BB=0
begin
IF EXISTS(SELECT * FROM CUSTOMER  C WHERE C.customer_name=@customer_name)
begin
INSERT INTO Admin_Customer_Giftcard values(@code,@customer_name,@admin_username);
UPDATE Admin_Customer_Giftcard
SET remaining_points=g.amount from giftcard g inner join Admin_Customer_Giftcard a on a.code=g.code where  a.code=@code and a.admin_username=@admin_username and a.customer_name=@customer_name;
update CUSTOMER
set points=g.amount+points from giftcard g inner join Admin_Customer_Giftcard a on a.code=g.code inner join CUSTOMER c on c.USERNAME=a.customer_name where  a.code=@code and a.admin_username=@admin_username and a.customer_name=@customer_name;
end
end


create proc acceptAdminInvitation
@delivery_username varchar(20)
as
update Delivery_Person set is_activated = 1 where username=@delivery_username
 




CREATE PROC deliveryPersonUpdateInfo
@username varchar(20),@first_name varchar(20),@last_name varchar(20),@password varchar(20),@email
varchar(50)
AS
IF EXISTS(SELECT * FROM Delivery_Person where @username=username)
UPDATE USERS 
SET email=@email,first_name=@first_name,last_name=@last_name,password=@password WHERE USERNAME=@username;



create proc viewmyorders
@deliveryperson varchar(20)
as
select o.order_no,o.total_amount, o.cash_amount,o. credit_amount,o.payment_type,o.order_status,o.remaining_days,o.time_limit,o.customer_name,o.delivery_id,o.creditCard_number,o.order_no,o.gift_card_used from orders o  inner join Admin_Delivery_Order a on a.order_no =o.order_no where a.delivery_username=@deliveryperson


CREATE PROC specifyDeliveryWindow
@delivery_username varchar(20),@order_no int,@delivery_window varchar(50)
AS
IF EXISTS(SELECT * FROM Admin_Delivery_Order where @delivery_username=delivery_username AND @order_no=order_no AND @delivery_window=delivery_window)
UPDATE Admin_Delivery_Order
SET delivery_window = @delivery_window WHERE delivery_username=@delivery_username and order_no=@order_no;


create proc updateOrderStatusOutforDelivery
@order_no int
as
update orders set order_status = 'out for delivery' where order_no=@order_no;



CREATE PROC updateOrderStatusDelivered
@order_no int
AS
UPDATE ORDERS
SET order_status='DELIVERED' WHERE order_no=@order_no;
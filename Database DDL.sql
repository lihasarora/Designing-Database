/* 

Group_Assignment_2: DDL Script Assignment 

Group 7 

@authors: Archit Patel(ajp4737), Charan Musunuru(cm59982), Divyansh Karki(dk27856), Sahil Arora(sa52643), Sukeerth Cheruvu(sc63232), Yashaswini Kalva(yk8348) 

*/ 

 

------------------------------------------------------------ 

-- CREATING ALL THE REQUIRED SEQUENCES 

-- @authors: Archit Patel (ajp4737), Charan Musunuru(cm59982), Divyansh Karki(dk27856), Sahil Arora (sa52643), Sukeerth Cheruvu  (sc63232), Yashaswini Kalva(yk8348) 

------------------------------------------------------------ 

 

CREATE SEQUENCE customer_sequence 

  MINVALUE 100001 

  START WITH 100001 

  INCREMENT BY 1 

  CACHE 20; 

CREATE SEQUENCE payment_sequence 

  MINVALUE 1 

  START WITH 1 

  INCREMENT BY 1 

  CACHE 20; 

CREATE SEQUENCE reservation_sequence 

  MINVALUE 1 

  START WITH 1 

  INCREMENT BY 1 

  CACHE 20; 

CREATE SEQUENCE room_sequence 

  MINVALUE 1 

  START WITH 1 

  INCREMENT BY 1 

  CACHE 20; 

CREATE SEQUENCE location_sequence 

  MINVALUE 1 

  START WITH 1 

  INCREMENT BY 1 

  CACHE 20; 

CREATE SEQUENCE feature_sequence 

  MINVALUE 1 

  START WITH 1 

  INCREMENT BY 1 

  CACHE 20; 

 

------------------------------------------------------------ 

-- CREATING ALL THE REQUIRED TABLES 

-- @authors: Archit Patel (ajp4737), Charan Musunuru(cm59982), Divyansh Karki(dk27856), Sahil Arora (sa52643), Sukeerth Cheruvu  (sc63232), Yashaswini Kalva(yk8348) 

------------------------------------------------------------ 

/*   

Creating Customer Table 

- Since Address_Line2 is not a mandatory field and since customers date of birth is not always known,  

defining these fields with acceptable Null values while creating Customers table 

- Constraints for Customer table :  

Stay_Credits_Earned is never less than Stay_Credits_Used; 

Length of the Email is atleast 7 characters 

*/ 

CREATE TABLE Customer ( 

Customer_ID NUMBER PRIMARY KEY, 

First_Name VARCHAR(50) NOT NULL, 

Last_Name VARCHAR(50) NOT NULL,  

Email VARCHAR(50) NOT NULL UNIQUE,  

Phone CHAR(12) NOT NULL CHECK(LENGTH(Phone)=12), 

Address_Line_1 VARCHAR(50) NOT NULL , 

Address_Line_2 VARCHAR(50), 

City VARCHAR(50) NOT NULL, 

State CHAR(2) NOT NULL CHECK(LENGTH(State)=2), 

Zip CHAR(5) NOT NULL CHECK(LENGTH(Zip)=5), 

Birthdate DATE, 

Stay_Credits_Earned NUMBER DEFAULT 0 NOT NULL , 

Stay_Credits_Used NUMBER DEFAULT 0 NOT NULL, 

CONSTRAINT CHK_Credits CHECK (Stay_Credits_Earned >= Stay_Credits_Used), 

CONSTRAINT email_length_check CHECK (LENGTH(Email) >= 7) 

); 


 

CREATE OR REPLACE TRIGGER cust_on_insert 

  BEFORE INSERT ON Customer 

  FOR EACH ROW 

BEGIN 

  SELECT customer_sequence.nextval 

  INTO :new.Customer_ID 

  FROM dual; 

END; 

/ 

 

/* 

Creation of Customer_Payments Table 

No Constraints are present for this table 

*/ 

 

CREATE TABLE Customer_Payment( 

Payment_ID NUMBER PRIMARY KEY, 

Customer_ID NUMBER NOT NULL, 

Cardholder_First_Name VARCHAR(50) NOT NULL, 

Cardholder_Mid_Name VARCHAR(50) NOT NULL, 

Cardholder_Last_Name VARCHAR(50) NOT NULL, 

CardType CHAR(4) NOT NULL CHECK(LENGTH(CardType)=4), 

CardNumber NUMBER NOT NULL, 

Expiration_Date DATE NOT NULL, 

CC_ID NUMBER NOT NULL, 

Billing_Address VARCHAR(200) NOT NULL, 

Billing_City VARCHAR(50) NOT NULL, 

Billing_State CHAR(2) NOT NULL CHECK(LENGTH(Billing_State)=2), 

Billing_Zip CHAR(5) NOT NULL CHECK(LENGTH(Billing_Zip)=5), 

FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID) 

); 

 

CREATE INDEX cust_payment_index 

ON Customer_Payment (Customer_ID); 

 

CREATE OR REPLACE TRIGGER cust_payment_on_insert 

  BEFORE INSERT ON Customer_Payment 

  FOR EACH ROW 

BEGIN 

  SELECT payment_sequence.nextval 

  INTO :new.Payment_ID 

  FROM dual; 

END; 

/ 

 

 

/* Below code creates the Reservation Table 

- Confirmation_Nbr can be no longer than 8 characters 

- We have also added a CHECK constraint to ensure that the sanity in length values for this column 

- Date_Created will be initialized with the system date by DEFAULT 

- Status column can only take values from a pre-defined list 

*/ 

  

  

CREATE TABLE Reservation ( 

Reservation_ID NUMBER PRIMARY KEY, 

Customer_ID NUMBER NOT NULL, 

Confirmation_Nbr CHAR(8) NOT NULL UNIQUE, 

Date_Created DATE DEFAULT SYSDATE NOT NULL, 

Check_In_Date DATE NOT NULL, 

Check_Out_Date DATE, 

Status CHAR(1) NOT NULL, 

Discount_Code VARCHAR(20), 

Reservation_Total NUMBER NOT NULL, 

Customer_Rating NUMBER, 

Notes VARCHAR(50), 

FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID), 

CONSTRAINT CHK_Status CHECK (Status in ('U','I','C','N','R')), 

CONSTRAINT Confirmation_Nbr_Len CHECK(LENGTH(Confirmation_Nbr)=8) 

); 

/* We believe that reservation date will be used frequently to filter this table thus we have created an indexed this column to ensure faster data retrieval 

*/ 

CREATE INDEX reservation_check_in_date_index 

ON Reservation (Check_in_Date); 

/* Status is frequently used by the staff to assess the quantum of cancelations/ bookings*/ 


CREATE INDEX reservation_status_index 

ON Reservation (Status); 



CREATE INDEX reservation_index 

ON Reservation (Customer_ID); 
 

CREATE OR REPLACE TRIGGER reservation_on_insert 

  BEFORE INSERT ON Reservation 

  FOR EACH ROW 

BEGIN 

  SELECT reservation_sequence.nextval 

  INTO :new.Reservation_ID 

  FROM dual; 

END; 

/ 

 

/*   

Creating Location Table 

-  Location_ID forms the primary key of the location table 

-  All columns have the not NOT NULL constraint except URL 

*/ 

 

CREATE TABLE Location ( 

Location_ID NUMBER PRIMARY KEY, 

Location_Name VARCHAR(50) UNIQUE NOT NULL, 

Address VARCHAR(200) NOT NULL, 

City VARCHAR(50) NOT NULL, 

State CHAR(2) NOT NULL CHECK(LENGTH(State)=2), 

Zip CHAR(5) NOT NULL CHECK(LENGTH(Zip)=5), 

Phone CHAR(12) NOT NULL CHECK(LENGTH(Phone) = 12), 

URL VARCHAR(50) 

); 

 

/*   

Creating the trigger location_on_insert to update the value of location_sequence Sequence  and store it in the location_ID column of Location 

*/ 

 

 

CREATE OR REPLACE TRIGGER location_on_insert 

  BEFORE INSERT ON Location 

  FOR EACH ROW 

BEGIN 

  SELECT location_sequence.nextval 

  INTO :new.Location_ID 

  FROM dual; 

END; 

/ 

 

/*   

Creating Room Table 

-  Location_ID forms the foreign key of the room table referencing the Location_ID of Location 

-  Room_ID is the primary key of the table 

- All the columns have a NOT NULL constraint 

-The room_type column has a constraint which can only take the characters ('D','Q','K','S','C') 

*/ 

 

CREATE TABLE Room ( 

Room_ID NUMBER PRIMARY KEY, 

Location_ID NUMBER NOT NULL, 

Floor NUMBER NOT NULL, 

Room_Number NUMBER NOT NULL, 

Room_Type CHAR(1) NOT NULL, 

Square_Footage NUMBER NOT NULL, 

Max_People NUMBER NOT NULL, 

Weekday_Rate NUMBER NOT NULL, 

Weekend_Rate NUMBER NOT NULL, 

FOREIGN KEY (Location_ID) REFERENCES Location (Location_ID), 

CONSTRAINT CHK_RoomType CHECK (Room_Type IN ('D','Q','K','S','C')) 

); 

 

--Creating the room_index index 

CREATE INDEX room_index 

ON Room (Location_ID); 



/* 

Creating the trigger to update the room_sequence Sequence as new records are entered and storing the value in the room_id column of rooms 

*/ 

CREATE OR REPLACE TRIGGER room_on_insert 

  BEFORE INSERT ON Room 

  FOR EACH ROW 

BEGIN 

  SELECT room_sequence.nextval 

  INTO :new.Room_ID 

  FROM dual; 

END; 

/ 

 

 

/* Reservation_Details table is a bridge table that helps to manage many : many relationship 

between Reservation and Room table 

	- This table has a composite key and is therefore created in the table level constraint	 

	- Since the foreign keys are also primary keys, we don't need to create index  

*/ 

  

CREATE TABLE Reservation_Details ( 

Reservation_ID NUMBER, 

Room_ID NUMBER, 

Number_of_Guests NUMBER NOT NULL, 

FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID), 

FOREIGN KEY (Reservation_ID) REFERENCES Reservation(Reservation_ID), 

CONSTRAINT pk PRIMARY KEY (Reservation_ID,Room_ID) 

); 

 

 

 

/*   

Creating Features Table 

-  Feature_ID forms the primary key of the table 

-  Feature_name is the other column of the table and has a not null and unique constraint 

*/ 

 

CREATE TABLE Features ( 

Feature_ID NUMBER PRIMARY KEY, 

Feature_Name VARCHAR(50) NOT NULL UNIQUE 

); 

 

/*  

Creating the trigger to update the feature_sequence Sequence as new records are entered and storing the value in Feature_ID in Features table 

*/ 

CREATE OR REPLACE TRIGGER feature_on_insert 

  BEFORE INSERT ON Features 

  FOR EACH ROW 

BEGIN 

  SELECT feature_sequence.nextval 

  INTO :new.Feature_ID 

  FROM dual; 

END; 

/ 

 

 

 

/*   

Creating Location_Feature_linking bridge Table 

-  Feature_ID and Location_ID together form the primary key of the table 

-  Feature_ID is the foreign key referencing Feature_ID in features table 

-  Location_ID is the foreign key referencing Location_ID in locations table 

*/ 

 

CREATE TABLE Location_Features_Linking ( 

Location_ID NUMBER, 

Feature_ID NUMBER, 

FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID), 

FOREIGN KEY (Feature_ID) REFERENCES Features(Feature_ID), 

CONSTRAINT pk_location_features PRIMARY KEY (Location_ID, Feature_ID) 

); 

 

 

------------------------------------------------------------ 

-- INSERTING VALUES INTO ALL THE TABLES CREATED 

-- @authors: Archit Patel (ajp4737), Charan Musunuru(cm59982), Divyansh Karki(dk27856), Sahil Arora (sa52643), Sukeerth Cheruvu  (sc63232), Yashaswini Kalva(yk8348) 

------------------------------------------------------------ 

 

INSERT ALL 

INTO Location (Location_Name, Address, City, State, Zip, Phone, URL) VALUES('South Congress', 'South Congress, East 7th Lofts', 'Austin', 'TX', '78701', '123-456-8910','sourapples.eastaustin.com') 

INTO Location (Location_Name, Address, City, State, Zip, Phone, URL) VALUES('Balcones Canyonlands Cabins', 'Balcones Canyonlands, West Austin', 'Austin', 'TX', '78702', '523-456-8910','sourapples.westaustin.com') 

INTO Location (Location_Name, Address, City, State, Zip, Phone, URL) VALUES('Marble Falls', 'Marble Falls, West Austin', 'Austin', 'TX', '78703', '111-222-3333','sourapples.marblefalls.com') 

SELECT 1 FROM DUAL; 

COMMIT; 

 

INSERT ALL 

INTO Features (Feature_Name) VALUES('Wi-Fi') 

INTO Features (Feature_Name) VALUES('Free Breakfast') 

INTO Features (Feature_Name) VALUES('Parking') 

SELECT 1 FROM DUAL; 

COMMIT; 

 

INSERT ALL 

INTO Location_Features_Linking (Location_ID, Feature_ID) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'South Congress'),(SELECT Feature_ID FROM Features WHERE Feature_Name = 'Wi-Fi')) 

INTO Location_Features_Linking (Location_ID, Feature_ID) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'South Congress'),(SELECT Feature_ID FROM Features WHERE Feature_Name = 'Free Breakfast')) 

 

INTO Location_Features_Linking (Location_ID, Feature_ID) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Balcones Canyonlands Cabins'),(SELECT Feature_ID FROM Features WHERE Feature_Name = 'Free Breakfast')) 

INTO Location_Features_Linking (Location_ID, Feature_ID) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Balcones Canyonlands Cabins'),(SELECT Feature_ID FROM Features WHERE Feature_Name = 'Parking')) 

 

INTO Location_Features_Linking (Location_ID, Feature_ID) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Marble Falls'),(SELECT Feature_ID FROM Features WHERE Feature_Name = 'Parking')) 

INTO Location_Features_Linking (Location_ID, Feature_ID) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Marble Falls'),(SELECT Feature_ID FROM Features WHERE Feature_Name = 'Wi-Fi')) 

 

SELECT 1 FROM DUAL; 

COMMIT; 

 

INSERT ALL 

INTO Room (Location_ID, Floor, Room_Number, Room_Type, Square_Footage, Max_People, Weekday_Rate, Weekend_Rate) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'South Congress'), 1, 101, 'D', 575, 2, 250, 350) 

INTO Room (Location_ID, Floor, Room_Number, Room_Type, Square_Footage, Max_People, Weekday_Rate, Weekend_Rate) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'South Congress'), 2, 201, 'Q', 675, 3, 350, 450) 

 

INTO Room (Location_ID, Floor, Room_Number, Room_Type, Square_Footage, Max_People, Weekday_Rate, Weekend_Rate) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Balcones Canyonlands Cabins'), 3, 311, 'K', 1000, 4, 500, 850) 

INTO Room (Location_ID, Floor, Room_Number, Room_Type, Square_Footage, Max_People, Weekday_Rate, Weekend_Rate) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Balcones Canyonlands Cabins'), 5, 545, 'S', 1200, 4, 600, 1050) 

 

INTO Room (Location_ID, Floor, Room_Number, Room_Type, Square_Footage, Max_People, Weekday_Rate, Weekend_Rate) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Marble Falls'), 4, 444, 'C', 1250, 4, 1500, 1850) 

INTO Room (Location_ID, Floor, Room_Number, Room_Type, Square_Footage, Max_People, Weekday_Rate, Weekend_Rate) VALUES ((SELECT Location_ID FROM Location WHERE Location_Name = 'Marble Falls'), 6, 666, 'D', 670, 2, 500, 750) 

 

SELECT 1 FROM DUAL; 

COMMIT; 

 

INSERT ALL 

INTO Customer (First_Name, Last_Name, Email, Phone, Address_Line_1, Address_Line_2, City, State, Zip, Birthdate) VALUES ('Sukeerth', 'Cheruvu', 'scheruvu@austin.utexas.edu', '111-222-3333','McCombs School of Business', 'Speedway', 'Austin', 'TX', '78701', TO_DATE('07/27/1995','MM/DD/YYYY')) 

INTO Customer (First_Name, Last_Name, Email, Phone, Address_Line_1, Address_Line_2, City, State, Zip, Birthdate) VALUES ('Harry', 'Potter', 'harry@potter.com', '222-333-4444','Hogwarts', 'Somewhere', 'Not Austin', 'TX', '00000', TO_DATE('07/31/1980','MM/DD/YYYY')) 

SELECT 1 FROM DUAL; 

COMMIT; 

 

INSERT ALL 

INTO Customer_Payment (Customer_ID, Cardholder_First_Name, Cardholder_Mid_Name, Cardholder_Last_Name, CardType, CardNumber, Expiration_Date, CC_ID, Billing_Address, Billing_City, Billing_State, Billing_Zip) 

VALUES (100001, 'Sukeerth','none', 'Cheruvu', 'MSTR', '111111111', TO_DATE('12/25/2025', 'MM/DD/YYYY'), '1234', 'West Avenue','Austin','TX','78701') 

INTO Customer_Payment (Customer_ID, Cardholder_First_Name, Cardholder_Mid_Name, Cardholder_Last_Name, CardType, CardNumber, Expiration_Date, CC_ID, Billing_Address, Billing_City, Billing_State, Billing_Zip) 

VALUES (100002, 'Harry', 'none','Potter', 'MSTR', '111111221', TO_DATE('4/17/2030', 'MM/DD/YYYY'), '1111', 'East Avenue','Austin','TX','78703') 

SELECT 1 FROM DUAL; 

COMMIT; 

 

/* Reservation for customer 1 */ 

INSERT INTO Reservation (Customer_ID, Confirmation_Nbr,  Check_In_Date, Status, Discount_Code, Reservation_Total, Customer_Rating, notes) 

VALUES (100001, 101, TO_DATE('10/05/2021', 'MM/DD/YYYY'), 'C', '',1500,'',''); 

COMMIT; 

 

INSERT INTO Reservation_Details (Reservation_ID, Room_ID, Number_of_Guests) 

VALUES ((SELECT Reservation_ID from Reservation WHERE Customer_ID = 100001 AND Check_In_Date = TO_DATE('10/05/2021','MM/DD/YYYY')),5,3); 

 

/* Reservation for customer 2 */ 

INSERT INTO Reservation (Customer_ID, Confirmation_Nbr,  Check_In_Date, Status, Discount_Code, Reservation_Total, Customer_Rating, notes) 

VALUES (100002, 102, TO_DATE('10/15/2021', 'MM/DD/YYYY'), 'C', '',750,'',''); 

COMMIT; 

 

INSERT ALL  

INTO Reservation_Details (Reservation_ID, Room_ID, Number_of_Guests) 

VALUES ((SELECT Reservation_ID from Reservation WHERE Customer_ID = 100002 AND Check_In_Date = TO_DATE('10/15/2021','MM/DD/YYYY')),1,3) 

 

INTO Reservation_Details (Reservation_ID, Room_ID, Number_of_Guests) 

VALUES ((SELECT Reservation_ID from Reservation WHERE Customer_ID = 100002 AND Check_In_Date = TO_DATE('10/15/2021','MM/DD/YYYY')),3,3) 

SELECT 1 FROM DUAL; 

COMMIT; 

 

 

------------------------------------------------------------ 

-- DROPPING ALL THE SEQUENCES AND TABLES 

-- @authors: Archit Patel (ajp4737), Charan Musunuru(cm59982), Divyansh Karki(dk27856), Sahil Arora (sa52643), Sukeerth Cheruvu  (sc63232), Yashaswini Kalva(yk8348) 

------------------------------------------------------------ 

 

-- DROP ALL THE TABLES  

 

DROP TABLE Location_Features_Linking; 

DROP TABLE Features; 

DROP TABLE Reservation_Details; 

DROP TABLE Room; 

DROP TABLE Location; 

DROP TABLE Reservation; 

DROP TABLE Customer_Payment; 

DROP TABLE Customer; 

 

--DROP ALL THE SEQUENCES 

 

DROP SEQUENCE customer_sequence; 

DROP SEQUENCE payment_sequence; 

DROP SEQUENCE reservation_sequence; 

DROP SEQUENCE room_sequence; 

DROP SEQUENCE location_sequence; 

DROP SEQUENCE feature_sequence; 
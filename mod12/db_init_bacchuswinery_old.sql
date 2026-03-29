/*
    Title: db_init_bacchuswinery.sql
    Author: Justin Morrow
    Date: 21 February 2025
    Description: Bacchus Winery Database Intilization script for CSD-310 Module 10.1 Project
	Team Members: Justin, Tabari, Austin and Mark
	This code is adapted from the db_init_2022.sql by Professor Sue for the movies database initialization script.
*/

-- create the Bacchus Winery database if it doesn't exist
CREATE DATABASE IF NOT EXISTS bacchuswinery;

-- selete the Bacchus Winery database for use
USE bacchuswinery;
	  
-- drop database user if exists 
DROP USER IF EXISTS 'winery_user'@'localhost';

-- create winery_user and grant them all privileges to the bacchus winery database 
CREATE USER 'winery_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Gr@pe$2025';

-- grant all privileges to the bacchus database to user winery_user on localhost
GRANT ALL PRIVILEGES ON bacchuswinery.* TO 'winery_user'@'localhost';

-- drop tables if they are present
-- https://stackoverflow.com/questions/65700447/cant-drop-table-because-of-a-foreign-key-but-also-cant-drop-foreign-key
SET foreign_key_checks =0;
DROP TABLE IF EXISTS distributors;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS supplier_deliveries;
DROP TABLE IF EXISTS wine_grape_variety;
DROP TABLE IF EXISTS wine_sales;
SET foreign_key_checks = 1;

-- create the distributors table
CREATE TABLE distributors (
    distributor_id INT NOT NULL AUTO_INCREMENT,
    distributor_name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    PRIMARY KEY(distributor_id)
);

-- create the employees table
CREATE TABLE employees (
    employee_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    total_hours_worked DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY(employee_id)
);

-- create the suppliers table
CREATE TABLE suppliers (
    supplier_id INT NOT NULL AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    supplied_item_type VARCHAR(255) NOT NULL,
    PRIMARY KEY(supplier_id)
);

-- create the supplier deliveries table - removed the discrepancy field since we will calculate with MySQL query or Python code
CREATE TABLE supplier_deliveries (
    delivery_id INT NOT NULL AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    item_type VARCHAR(255) NOT NULL,
    expected_delivery_date DATE NOT NULL,
    actual_delivery_date DATE,
    quantity_delivered INT NOT NULL,
    PRIMARY KEY(delivery_id),
    CONSTRAINT fk_supplier
	FOREIGN KEY(supplier_id)
		REFERENCES suppliers(supplier_id)
);

-- create the wine and grape variety table
CREATE TABLE wine_grape_variety (
    product_id INT NOT NULL AUTO_INCREMENT,
    wine_name VARCHAR(255) NOT NULL,
    grape_variety VARCHAR(255) NOT NULL,
    vintage_year YEAR NOT NULL,
    PRIMARY KEY(product_id)
);

-- create the wine sales table
CREATE TABLE wine_sales (
    sale_id INT NOT NULL AUTO_INCREMENT,
    product_id INT NOT NULL,
    distributor_id INT NOT NULL,
    sales_quantity INT NOT NULL,
    sale_date DATE NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY(sale_id),
    CONSTRAINT fk_product
	FOREIGN KEY(product_id)
		REFERENCES wine_grape_variety(product_id),
    CONSTRAINT fk_distributor
	FOREIGN KEY(distributor_id)
		REFERENCES distributors(distributor_id)
);

-- insert the distributors records
INSERT INTO distributors(distributor_name, contact_info)
VALUES('Austin Spirits', 'awiant@my365.bellevue.edu'),
      ('Makers Mark', 'majoiner@my365.bellevue.edu'),
	  ('Just in Time', 'jumorrow@my365.bellevue.edu'),
	  ('Tabari Distillery', 'tlharvey@my365.bellevue.edu');
	  
-- insert the employees records
INSERT INTO employees(first_name, last_name, position, total_hours_worked) 
VALUES('Janet', 'Collins', 'Finance Manager', 1500),
      ('Roz', 'Murphy', 'Marketing Manager', 1200),
      ('Bob', 'Ulrich', 'Marketing Assistant', 1024),
      ('Henry', 'Doyle', 'Production Manager', 2048),
      ('Maria', 'Costanza', 'Distribution Manager', 2400);

-- insert the suppliers records
INSERT INTO suppliers(supplier_name, location, supplied_item_type) 
VALUES('Put a cork in it', 'California', 'Bottles/Corks'),
      ('Label this', 'Nevada', 'Labels/Boxes'),
      ('Vat Man', 'Washington', 'Vats/ Tubing');

-- insert the supplier deliveries records
INSERT INTO supplier_deliveries(supplier_id, item_type, expected_delivery_date, actual_delivery_date, quantity_delivered) 
VALUES
    ((SELECT supplier_id FROM suppliers WHERE supplier_name = 'Put a cork in it'), 'Bottles', '2025-01-05', '2025-01-05', 120000),
    ((SELECT supplier_id FROM suppliers WHERE supplier_name = 'Put a cork in it'), 'Corks', '2025-01-05', '2025-01-15', 120000),	
    ((SELECT supplier_id FROM suppliers WHERE supplier_name = 'Label this'), 'Labels', '2025-01-10', '2025-01-10', 10000),
    ((SELECT supplier_id FROM suppliers WHERE supplier_name = 'Label this'), 'Boxes', '2025-02-15', '2025-02-20', 10000),
    ((SELECT supplier_id FROM suppliers WHERE supplier_name = 'Vat Man'), 'Vats', '2025-01-12', '2025-02-20', 1000),
    ((SELECT supplier_id FROM suppliers WHERE supplier_name = 'Vat Man'), 'Tubing', '2025-01-12', '2025-01-12', 1000);

-- insert the wines and grape varieties records
INSERT INTO wine_grape_variety(wine_name, grape_variety, vintage_year)
VALUES('Austins Merlot Mystique', 'Merlot', 2015),
      ('Marks Zinfandel Zen', 'Zinfandel', 2010),
      ('Justins Chardonnay Charm', 'Chardonnay', 2017),
      ('Tabari Breeze', 'Sauvignon Blanc', 2012);

-- insert the records for wine sales
INSERT INTO wine_sales(product_id, distributor_id, sales_quantity, sale_date, price_per_unit) 
VALUES((SELECT product_id FROM wine_grape_variety WHERE wine_name = 'Austins Merlot Mystique'), (SELECT distributor_id FROM distributors WHERE distributor_name = 'Austin Spirits'), 30000, '2025-01-02', 20.99),
      ((SELECT product_id FROM wine_grape_variety WHERE wine_name = 'Marks Zinfandel Zen'), (SELECT distributor_id FROM distributors WHERE distributor_name = 'Makers Mark'), 30000, '2025-01-02', 15.50),
	  ((SELECT product_id FROM wine_grape_variety WHERE wine_name = 'Justins Chardonnay Charm'), (SELECT distributor_id FROM distributors WHERE distributor_name = 'Just in Time'), 30000, '2025-01-02', 25.49),
	  ((SELECT product_id FROM wine_grape_variety WHERE wine_name = 'Tabari Breeze'), (SELECT distributor_id FROM distributors WHERE distributor_name = 'Tabari Distillery'), 30000, '2025-01-02', 22.00);
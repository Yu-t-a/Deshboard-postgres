-- Set timezone
SET timezone = 'Asia/Bangkok';

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- ==============================================
-- MM (Materials Management) Module
-- ==============================================

-- ตาราง Material Master
CREATE TABLE mm_materials (
    material_id VARCHAR(18) PRIMARY KEY,
    material_desc VARCHAR(40) NOT NULL,
    material_type VARCHAR(4) NOT NULL,
    industry_sector VARCHAR(1),
    base_unit VARCHAR(3) NOT NULL,
    material_group VARCHAR(9),
    gross_weight DECIMAL(13,3),
    net_weight DECIMAL(13,3),
    weight_unit VARCHAR(3),
    created_date DATE DEFAULT CURRENT_DATE,
    created_by VARCHAR(12),
    plant VARCHAR(4)
);

-- ตาราง Vendor Master
CREATE TABLE mm_vendors (
    vendor_id VARCHAR(10) PRIMARY KEY,
    vendor_name VARCHAR(35) NOT NULL,
    vendor_type VARCHAR(4),
    country VARCHAR(3),
    region VARCHAR(3),
    city VARCHAR(35),
    postal_code VARCHAR(10),
    street VARCHAR(35),
    telephone VARCHAR(16),
    email VARCHAR(241),
    payment_terms VARCHAR(4),
    currency VARCHAR(3),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Purchase Orders
CREATE TABLE mm_purchase_orders (
    po_number VARCHAR(10) PRIMARY KEY,
    vendor_id VARCHAR(10) REFERENCES mm_vendors(vendor_id),
    po_date DATE NOT NULL,
    currency VARCHAR(3),
    exchange_rate DECIMAL(9,5),
    total_amount DECIMAL(15,2),
    payment_terms VARCHAR(4),
    delivery_date DATE,
    purchasing_org VARCHAR(4),
    purchasing_group VARCHAR(3),
    status VARCHAR(2),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Purchase Order Items
CREATE TABLE mm_po_items (
    po_number VARCHAR(10) REFERENCES mm_purchase_orders(po_number),
    item_number VARCHAR(5),
    material_id VARCHAR(18) REFERENCES mm_materials(material_id),
    quantity DECIMAL(13,3) NOT NULL,
    unit VARCHAR(3),
    price DECIMAL(11,2),
    amount DECIMAL(15,2),
    delivery_date DATE,
    plant VARCHAR(4),
    storage_location VARCHAR(4),
    PRIMARY KEY (po_number, item_number)
);

-- ==============================================
-- SD (Sales & Distribution) Module
-- ==============================================

-- ตาราง Customer Master
CREATE TABLE sd_customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(35) NOT NULL,
    customer_type VARCHAR(4),
    country VARCHAR(3),
    region VARCHAR(3),
    city VARCHAR(35),
    postal_code VARCHAR(10),
    street VARCHAR(35),
    telephone VARCHAR(16),
    email VARCHAR(241),
    payment_terms VARCHAR(4),
    currency VARCHAR(3),
    credit_limit DECIMAL(15,2),
    sales_org VARCHAR(4),
    distribution_channel VARCHAR(2),
    division VARCHAR(2),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Sales Orders
CREATE TABLE sd_sales_orders (
    sales_order VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) REFERENCES sd_customers(customer_id),
    order_date DATE NOT NULL,
    currency VARCHAR(3),
    exchange_rate DECIMAL(9,5),
    total_amount DECIMAL(15,2),
    payment_terms VARCHAR(4),
    requested_delivery_date DATE,
    sales_org VARCHAR(4),
    distribution_channel VARCHAR(2),
    division VARCHAR(2),
    order_type VARCHAR(4),
    status VARCHAR(2),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Sales Order Items
CREATE TABLE sd_so_items (
    sales_order VARCHAR(10) REFERENCES sd_sales_orders(sales_order),
    item_number VARCHAR(6),
    material_id VARCHAR(18) REFERENCES mm_materials(material_id),
    quantity DECIMAL(15,3) NOT NULL,
    unit VARCHAR(3),
    price DECIMAL(11,2),
    amount DECIMAL(15,2),
    requested_delivery_date DATE,
    plant VARCHAR(4),
    storage_location VARCHAR(4),
    PRIMARY KEY (sales_order, item_number)
);

-- ตาราง Billing Documents
CREATE TABLE sd_billing (
    billing_doc VARCHAR(10) PRIMARY KEY,
    sales_order VARCHAR(10) REFERENCES sd_sales_orders(sales_order),
    customer_id VARCHAR(10) REFERENCES sd_customers(customer_id),
    billing_date DATE NOT NULL,
    currency VARCHAR(3),
    total_amount DECIMAL(15,2),
    tax_amount DECIMAL(15,2),
    net_amount DECIMAL(15,2),
    billing_type VARCHAR(4),
    status VARCHAR(2),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ==============================================
-- PP (Production Planning) Module
-- ==============================================

-- ตาราง Production Orders
CREATE TABLE pp_production_orders (
    production_order VARCHAR(12) PRIMARY KEY,
    material_id VARCHAR(18) REFERENCES mm_materials(material_id),
    plant VARCHAR(4),
    order_type VARCHAR(4),
    quantity DECIMAL(13,3) NOT NULL,
    unit VARCHAR(3),
    start_date DATE,
    finish_date DATE,
    actual_start_date DATE,
    actual_finish_date DATE,
    status VARCHAR(4),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Work Centers
CREATE TABLE pp_work_centers (
    work_center_id VARCHAR(8) PRIMARY KEY,
    work_center_name VARCHAR(40),
    plant VARCHAR(4),
    capacity_category VARCHAR(8),
    standard_capacity DECIMAL(9,3),
    capacity_unit VARCHAR(3),
    cost_center VARCHAR(10),
    person_responsible VARCHAR(3),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Bill of Materials (BOM)
CREATE TABLE pp_bom_header (
    bom_id VARCHAR(8) PRIMARY KEY,
    material_id VARCHAR(18) REFERENCES mm_materials(material_id),
    plant VARCHAR(4),
    bom_usage VARCHAR(1),
    alternative_bom VARCHAR(2),
    base_quantity DECIMAL(13,3),
    base_unit VARCHAR(3),
    status VARCHAR(2),
    valid_from DATE,
    valid_to DATE,
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง BOM Items
CREATE TABLE pp_bom_items (
    bom_id VARCHAR(8) REFERENCES pp_bom_header(bom_id),
    item_number VARCHAR(4),
    component_material VARCHAR(18) REFERENCES mm_materials(material_id),
    component_quantity DECIMAL(13,3),
    component_unit VARCHAR(3),
    item_category VARCHAR(1),
    PRIMARY KEY (bom_id, item_number)
);

-- ==============================================
-- FI/CO (Financial Accounting/Controlling) Module
-- ==============================================

-- ตาราง Chart of Accounts
CREATE TABLE fi_chart_accounts (
    account_number VARCHAR(10) PRIMARY KEY,
    account_name VARCHAR(50) NOT NULL,
    account_group VARCHAR(4),
    account_type VARCHAR(1),
    balance_sheet_account BOOLEAN DEFAULT FALSE,
    pl_account BOOLEAN DEFAULT FALSE,
    currency VARCHAR(3),
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง Cost Centers
CREATE TABLE co_cost_centers (
    cost_center VARCHAR(10) PRIMARY KEY,
    cost_center_name VARCHAR(40) NOT NULL,
    responsible_person VARCHAR(12),
    company_code VARCHAR(4),
    controlling_area VARCHAR(4),
    cost_center_category VARCHAR(2),
    hierarchy_area VARCHAR(12),
    valid_from DATE,
    valid_to DATE,
    created_date DATE DEFAULT CURRENT_DATE
);

-- ตาราง General Ledger
CREATE TABLE fi_general_ledger (
    document_number VARCHAR(10),
    company_code VARCHAR(4),
    fiscal_year VARCHAR(4),
    line_item VARCHAR(3),
    account_number VARCHAR(10) REFERENCES fi_chart_accounts(account_number),
    posting_date DATE NOT NULL,
    document_date DATE,
    document_type VARCHAR(2),
    reference VARCHAR(16),
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3),
    cost_center VARCHAR(10) REFERENCES co_cost_centers(cost_center),
    posting_key VARCHAR(2),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (document_number, company_code, fiscal_year, line_item)
);

-- ตาราง Accounts Payable
CREATE TABLE fi_accounts_payable (
    document_number VARCHAR(10),
    company_code VARCHAR(4),
    fiscal_year VARCHAR(4),
    line_item VARCHAR(3),
    vendor_id VARCHAR(10) REFERENCES mm_vendors(vendor_id),
    posting_date DATE NOT NULL,
    due_date DATE,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3),
    payment_terms VARCHAR(4),
    reference VARCHAR(16),
    status VARCHAR(1),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (document_number, company_code, fiscal_year, line_item)
);

-- ตาราง Accounts Receivable
CREATE TABLE fi_accounts_receivable (
    document_number VARCHAR(10),
    company_code VARCHAR(4),
    fiscal_year VARCHAR(4),
    line_item VARCHAR(3),
    customer_id VARCHAR(10) REFERENCES sd_customers(customer_id),
    posting_date DATE NOT NULL,
    due_date DATE,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3),
    payment_terms VARCHAR(4),
    reference VARCHAR(16),
    status VARCHAR(1),
    created_by VARCHAR(12),
    created_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (document_number, company_code, fiscal_year, line_item)
);


INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000001', 'Material 1', 'VERP', 'C', 'EA', '377451781', 44.900, 34.623, 'KG', '2025-06-06', 'USR011', '1200');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000002', 'Material 2', 'HALB', 'C', 'EA', '101803357', 75.638, 41.063, 'KG', '2025-06-06', 'USR025', '1000');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000003', 'Material 3', 'VERP', 'A', 'EA', '329604087', 5.537, 31.896, 'KG', '2025-06-06', 'USR074', '1000');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000004', 'Material 4', 'VERP', 'M', 'KG', '157516227', 8.911, 17.306, 'KG', '2025-06-06', 'USR028', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000005', 'Material 5', 'HALB', 'M', 'EA', '470597700', 32.853, 23.218, 'KG', '2025-06-06', 'USR039', '1000');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000006', 'Material 6', 'ROH', 'C', 'KG', '896360087', 81.958, 15.349, 'KG', '2025-06-06', 'USR048', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000007', 'Material 7', 'FERT', 'M', 'EA', '950438247', 26.164, 72.776, 'KG', '2025-06-06', 'USR071', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000008', 'Material 8', 'FERT', 'M', 'L', '834048471', 44.855, 47.435, 'KG', '2025-06-06', 'USR039', '1200');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000009', 'Material 9', 'ROH', 'C', 'KG', '285305924', 95.551, 98.479, 'KG', '2025-06-06', 'USR015', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000010', 'Material 10', 'FERT', 'C', 'EA', '896840673', 70.732, 82.870, 'KG', '2025-06-06', 'USR079', '1200');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000011', 'Material 11', 'FERT', 'C', 'KG', '902647852', 96.889, 50.542, 'KG', '2025-06-06', 'USR057', '1000');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000012', 'Material 12', 'VERP', 'M', 'EA', '468614721', 31.602, 40.520, 'KG', '2025-06-06', 'USR016', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000013', 'Material 13', 'VERP', 'C', 'L', '140083424', 86.545, 34.257, 'KG', '2025-06-06', 'USR079', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000014', 'Material 14', 'ROH', 'M', 'EA', '666704059', 96.614, 80.221, 'KG', '2025-06-06', 'USR091', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000015', 'Material 15', 'VERP', 'M', 'L', '530912353', 45.722, 7.922, 'KG', '2025-06-06', 'USR030', '1200');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000016', 'Material 16', 'FERT', 'C', 'EA', '863570766', 43.452, 79.692, 'KG', '2025-06-06', 'USR013', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000017', 'Material 17', 'VERP', 'A', 'KG', '307965481', 26.367, 60.249, 'KG', '2025-06-06', 'USR014', '1000');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000018', 'Material 18', 'VERP', 'M', 'KG', '789916016', 24.454, 85.423, 'KG', '2025-06-06', 'USR010', '1000');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000019', 'Material 19', 'VERP', 'A', 'KG', '720948142', 80.953, 90.427, 'KG', '2025-06-06', 'USR091', '1100');
INSERT INTO mm_materials (material_id, material_desc, material_type, industry_sector, base_unit, material_group, gross_weight, net_weight, weight_unit, created_date, created_by, plant) VALUES ('MAT000020', 'Material 20', 'HALB', 'C', 'EA', '433780310', 10.938, 25.768, 'KG', '2025-06-06', 'USR017', '1000');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00001', 'Vendor 1', 'LIEF', 'DE', 'TY', 'City1', '99526', '663 Main St', '+29479968154', 'vendor1@example.com', '0030', 'EUR', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00002', 'Vendor 2', 'KRED', 'TH', 'LA', 'City2', '49777', '339 Main St', '+9532293438', 'vendor2@example.com', '0002', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00003', 'Vendor 3', 'KRED', 'TH', 'VU', 'City3', '43954', '233 Main St', '+69436637250', 'vendor3@example.com', '0001', 'USD', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00004', 'Vendor 4', 'SERV', 'US', 'JC', 'City4', '94543', '220 Main St', '+52483530658', 'vendor4@example.com', '0001', 'THB', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00005', 'Vendor 5', 'LIEF', 'US', 'LA', 'City5', '44745', '561 Main St', '+8620940951', 'vendor5@example.com', '0002', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00006', 'Vendor 6', 'SERV', 'CN', 'KJ', 'City6', '76306', '852 Main St', '+3225799985', 'vendor6@example.com', '0001', 'THB', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00007', 'Vendor 7', 'LIEF', 'CN', 'EI', 'City7', '86726', '197 Main St', '+21292623453', 'vendor7@example.com', '0001', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00008', 'Vendor 8', 'KRED', 'DE', 'LE', 'City8', '52732', '625 Main St', '+80945670212', 'vendor8@example.com', '0001', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00009', 'Vendor 9', 'LIEF', 'TH', 'VX', 'City9', '51951', '464 Main St', '+94422348705', 'vendor9@example.com', '0001', 'THB', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00010', 'Vendor 10', 'LIEF', 'CN', 'ZJ', 'City10', '15529', '847 Main St', '+6392573506', 'vendor10@example.com', '0001', 'USD', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00011', 'Vendor 11', 'KRED', 'TH', 'AK', 'City11', '57340', '809 Main St', '+76721803665', 'vendor11@example.com', '0030', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00012', 'Vendor 12', 'KRED', 'US', 'XO', 'City12', '25046', '351 Main St', '+83188654246', 'vendor12@example.com', '0001', 'THB', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00013', 'Vendor 13', 'KRED', 'CN', 'JS', 'City13', '26588', '700 Main St', '+23679575899', 'vendor13@example.com', '0030', 'USD', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00014', 'Vendor 14', 'KRED', 'TH', 'FT', 'City14', '96314', '383 Main St', '+32661110080', 'vendor14@example.com', '0030', 'USD', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00015', 'Vendor 15', 'SERV', 'TH', 'PJ', 'City15', '92783', '290 Main St', '+51827040866', 'vendor15@example.com', '0002', 'THB', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00016', 'Vendor 16', 'SERV', 'US', 'RV', 'City16', '25071', '989 Main St', '+35283430316', 'vendor16@example.com', '0030', 'EUR', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00017', 'Vendor 17', 'LIEF', 'US', 'UC', 'City17', '27674', '126 Main St', '+41463365700', 'vendor17@example.com', '0030', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00018', 'Vendor 18', 'KRED', 'DE', 'WN', 'City18', '38732', '204 Main St', '+92472173706', 'vendor18@example.com', '0001', 'EUR', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00019', 'Vendor 19', 'SERV', 'US', 'HL', 'City19', '34167', '835 Main St', '+75997433408', 'vendor19@example.com', '0001', 'CNY', '2025-06-06');
INSERT INTO mm_vendors (vendor_id, vendor_name, vendor_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, created_date) VALUES ('V00020', 'Vendor 20', 'SERV', 'DE', 'WK', 'City20', '81490', '53 Main St', '+56272582035', 'vendor20@example.com', '0030', 'USD', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000001', 'V00006', '2023-06-03', 'THB', 36.74520, 94980.61, '0002', '2025-09-10', '1100', 'SRX', 'CL', 'USR023', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000002', 'V00014', '2024-06-03', 'THB', 22.35438, 85799.27, '0001', '2024-02-18', '1000', 'MJU', 'OP', 'USR070', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000003', 'V00003', '2024-06-12', 'USD', 3.07399, 81028.99, '0002', '2026-01-31', '1000', 'QXD', 'CL', 'USR037', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000004', 'V00014', '2023-08-06', 'USD', 34.88447, 59021.81, '0030', '2026-04-20', '1000', 'LMZ', 'CL', 'USR056', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000005', 'V00005', '2023-10-26', 'USD', 37.62627, 2173.90, '0030', '2025-03-19', '1000', 'IAO', 'CL', 'USR069', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000006', 'V00013', '2024-07-02', 'EUR', 24.23801, 97533.10, '0001', '2025-03-20', '1100', 'VAV', 'CL', 'USR065', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000007', 'V00013', '2023-02-27', 'EUR', 21.58219, 89883.29, '0030', '2024-02-22', '1100', 'WFC', 'CL', 'USR016', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000008', 'V00012', '2025-03-04', 'USD', 7.30999, 76442.36, '0030', '2024-01-26', '1000', 'JRJ', 'OP', 'USR006', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000009', 'V00010', '2023-03-14', 'EUR', 21.66499, 57300.48, '0030', '2026-04-30', '1100', 'DUE', 'CL', 'USR059', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000010', 'V00012', '2024-09-25', 'USD', 14.63952, 91556.59, '0030', '2026-01-13', '1100', 'WUB', 'CL', 'USR041', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000011', 'V00019', '2025-10-04', 'CNY', 32.20419, 89171.14, '0030', '2026-10-20', '1000', 'KIK', 'CL', 'USR022', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000012', 'V00019', '2023-06-20', 'CNY', 38.72783, 2544.34, '0002', '2026-02-10', '1000', 'NGS', 'CL', 'USR001', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000013', 'V00009', '2025-11-25', 'THB', 26.11801, 29387.09, '0030', '2026-12-03', '1100', 'ZGV', 'CL', 'USR072', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000014', 'V00009', '2025-04-27', 'USD', 38.60683, 32364.63, '0001', '2024-02-28', '1100', 'VCW', 'OP', 'USR044', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000015', 'V00008', '2025-10-13', 'CNY', 32.79915, 56167.75, '0002', '2026-01-13', '1100', 'UEK', 'OP', 'USR026', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000016', 'V00010', '2024-04-22', 'CNY', 11.02285, 40896.85, '0030', '2024-12-07', '1100', 'LUQ', 'OP', 'USR069', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000017', 'V00015', '2024-10-06', 'THB', 3.53369, 24573.87, '0001', '2026-08-07', '1000', 'NWK', 'CL', 'USR010', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000018', 'V00020', '2024-12-04', 'USD', 36.73087, 41714.68, '0002', '2025-09-26', '1100', 'XZC', 'CL', 'USR031', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000019', 'V00017', '2023-02-01', 'THB', 7.79392, 59982.87, '0002', '2024-08-12', '1100', 'RMY', 'CL', 'USR081', '2025-06-06');
INSERT INTO mm_purchase_orders (po_number, vendor_id, po_date, currency, exchange_rate, total_amount, payment_terms, delivery_date, purchasing_org, purchasing_group, status, created_by, created_date) VALUES ('PO000020', 'V00002', '2025-03-31', 'USD', 9.72256, 73677.79, '0030', '2024-04-25', '1100', 'CHL', 'CL', 'USR045', '2025-06-06');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000019', '00001', 'MAT000012', 558.889, 'L', 49.28, 27542.05, '2024-04-10', '1100', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000011', '00002', 'MAT000013', 972.463, 'L', 770.74, 749516.13, '2025-07-08', '1000', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000011', '00003', 'MAT000004', 344.851, 'EA', 829.53, 286064.25, '2025-01-11', '1100', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000006', '00004', 'MAT000019', 785.952, 'KG', 66.40, 52187.21, '2024-05-31', '1100', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000015', '00005', 'MAT000002', 974.871, 'L', 969.46, 945098.44, '2025-04-13', '1000', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000005', '00006', 'MAT000020', 642.880, 'EA', 184.35, 118514.93, '2025-02-01', '1100', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000012', '00007', 'MAT000009', 2.323, 'L', 72.46, 168.32, '2024-06-23', '1000', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000007', '00008', 'MAT000014', 225.037, 'KG', 725.56, 163277.85, '2026-08-02', '1000', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000013', '00009', 'MAT000007', 587.862, 'KG', 16.06, 9441.06, '2024-03-06', '1100', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000017', '00010', 'MAT000017', 54.637, 'L', 671.47, 36687.11, '2026-12-13', '1000', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000020', '00011', 'MAT000011', 414.755, 'KG', 377.22, 156453.88, '2024-06-10', '1100', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000017', '00012', 'MAT000003', 422.073, 'KG', 169.49, 71537.15, '2025-10-04', '1100', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000019', '00013', 'MAT000007', 749.831, 'L', 500.15, 375027.97, '2024-10-11', '1000', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000004', '00014', 'MAT000020', 603.490, 'EA', 852.26, 514330.39, '2026-10-05', '1000', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000002', '00015', 'MAT000005', 4.042, 'L', 594.99, 2404.95, '2026-05-13', '1000', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000016', '00016', 'MAT000017', 338.881, 'L', 763.75, 258820.36, '2024-10-01', '1000', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000005', '00017', 'MAT000004', 377.441, 'KG', 233.98, 88313.65, '2026-03-21', '1100', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000010', '00018', 'MAT000015', 179.175, 'KG', 36.12, 6471.80, '2025-11-20', '1000', '0001');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000010', '00019', 'MAT000019', 467.099, 'KG', 773.46, 361282.39, '2026-12-01', '1000', '0002');
INSERT INTO mm_po_items (po_number, item_number, material_id, quantity, unit, price, amount, delivery_date, plant, storage_location) VALUES ('PO000018', '00020', 'MAT000016', 603.806, 'KG', 706.79, 426764.04, '2025-03-03', '1000', '0001');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00001', 'Customer 1', 'CUST', 'CN', 'ZR', 'City1', '47228', '989 Market St', '+35884387588', 'customer1@example.com', '0002', 'USD', 125889.10, '1000', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00002', 'Customer 2', 'RETL', 'CN', 'YQ', 'City2', '61745', '985 Market St', '+59920150809', 'customer2@example.com', '0002', 'CNY', 85988.25, '1000', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00003', 'Customer 3', 'CUST', 'US', 'JB', 'City3', '30896', '962 Market St', '+91613644463', 'customer3@example.com', '0002', 'THB', 175018.33, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00004', 'Customer 4', 'RETL', 'US', 'VP', 'City4', '77758', '376 Market St', '+29310173801', 'customer4@example.com', '0001', 'CNY', 296727.19, '1100', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00005', 'Customer 5', 'CUST', 'CN', 'NM', 'City5', '27360', '340 Market St', '+36100406174', 'customer5@example.com', '0001', 'CNY', 493122.59, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00006', 'Customer 6', 'CUST', 'DE', 'EE', 'City6', '26181', '737 Market St', '+20499435546', 'customer6@example.com', '0002', 'EUR', 23561.49, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00007', 'Customer 7', 'DIST', 'DE', 'ER', 'City7', '52565', '669 Market St', '+85329106172', 'customer7@example.com', '0030', 'USD', 420094.76, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00008', 'Customer 8', 'CUST', 'TH', 'XM', 'City8', '22019', '389 Market St', '+58197491592', 'customer8@example.com', '0002', 'USD', 61782.80, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00009', 'Customer 9', 'CUST', 'TH', 'XR', 'City9', '17363', '977 Market St', '+63515236976', 'customer9@example.com', '0030', 'CNY', 313607.04, '1000', '10', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00010', 'Customer 10', 'DIST', 'US', 'MB', 'City10', '89490', '436 Market St', '+69307422324', 'customer10@example.com', '0001', 'THB', 352668.03, '1100', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00011', 'Customer 11', 'DIST', 'DE', 'BG', 'City11', '58802', '843 Market St', '+50904630366', 'customer11@example.com', '0002', 'CNY', 107686.53, '1000', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00012', 'Customer 12', 'DIST', 'US', 'XG', 'City12', '17120', '408 Market St', '+6704716545', 'customer12@example.com', '0030', 'USD', 324791.78, '1100', '10', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00013', 'Customer 13', 'DIST', 'TH', 'AO', 'City13', '65482', '289 Market St', '+88261148932', 'customer13@example.com', '0002', 'EUR', 343244.97, '1100', '10', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00014', 'Customer 14', 'RETL', 'CN', 'RY', 'City14', '66821', '553 Market St', '+60582184840', 'customer14@example.com', '0001', 'THB', 415577.85, '1100', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00015', 'Customer 15', 'RETL', 'CN', 'KA', 'City15', '75028', '186 Market St', '+30270331825', 'customer15@example.com', '0002', 'USD', 172092.06, '1100', '10', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00016', 'Customer 16', 'DIST', 'DE', 'NL', 'City16', '71695', '759 Market St', '+74865430745', 'customer16@example.com', '0030', 'THB', 303824.89, '1000', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00017', 'Customer 17', 'RETL', 'TH', 'LL', 'City17', '76824', '610 Market St', '+73898080795', 'customer17@example.com', '0030', 'THB', 243328.37, '1000', '10', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00018', 'Customer 18', 'RETL', 'CN', 'DX', 'City18', '63838', '502 Market St', '+29934244988', 'customer18@example.com', '0030', 'USD', 445406.61, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00019', 'Customer 19', 'CUST', 'TH', 'ZC', 'City19', '89090', '276 Market St', '+57706244724', 'customer19@example.com', '0030', 'USD', 123176.29, '1100', '20', '01', '2025-06-06');
INSERT INTO sd_customers (customer_id, customer_name, customer_type, country, region, city, postal_code, street, telephone, email, payment_terms, currency, credit_limit, sales_org, distribution_channel, division, created_date) VALUES ('C00020', 'Customer 20', 'DIST', 'TH', 'RW', 'City20', '30528', '663 Market St', '+23218126533', 'customer20@example.com', '0001', 'CNY', 336744.43, '1100', '20', '02', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000001', 'C00001', '2023-03-06', 'USD', 25.81371, 42608.20, '0030', '2026-02-14', '1000', '10', '02', 'RA', 'OP', 'USR043', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000002', 'C00006', '2024-07-30', 'CNY', 29.55750, 80305.72, '0002', '2026-11-04', '1100', '10', '02', 'OR', 'CL', 'USR010', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000003', 'C00005', '2024-02-15', 'EUR', 24.65612, 72315.66, '0002', '2025-12-28', '1100', '10', '02', 'FD', 'CL', 'USR005', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000004', 'C00009', '2025-09-22', 'CNY', 35.30129, 66749.02, '0002', '2024-10-05', '1000', '10', '01', 'FD', 'CL', 'USR035', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000005', 'C00012', '2023-05-30', 'CNY', 26.46049, 1946.40, '0002', '2026-12-29', '1100', '20', '01', 'RA', 'OP', 'USR067', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000006', 'C00005', '2024-01-29', 'EUR', 3.07862, 93569.96, '0030', '2025-03-08', '1000', '10', '02', 'RA', 'OP', 'USR052', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000007', 'C00020', '2025-09-04', 'EUR', 16.02026, 69094.20, '0030', '2026-03-21', '1000', '10', '02', 'OR', 'OP', 'USR007', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000008', 'C00009', '2024-08-23', 'THB', 22.87867, 49774.25, '0002', '2026-10-28', '1100', '10', '02', 'FD', 'CL', 'USR036', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000009', 'C00019', '2024-11-05', 'EUR', 15.46606, 50108.90, '0001', '2026-07-31', '1100', '10', '02', 'OR', 'CL', 'USR079', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000010', 'C00016', '2025-11-10', 'EUR', 21.55146, 17030.02, '0030', '2025-12-24', '1100', '10', '01', 'OR', 'CL', 'USR001', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000011', 'C00003', '2024-05-22', 'EUR', 34.84792, 37382.01, '0002', '2026-10-30', '1000', '10', '02', 'FD', 'OP', 'USR039', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000012', 'C00003', '2024-02-11', 'USD', 33.34771, 43876.55, '0002', '2026-02-17', '1000', '20', '01', 'RA', 'OP', 'USR032', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000013', 'C00002', '2025-01-19', 'THB', 25.74111, 52348.66, '0001', '2024-01-29', '1100', '10', '01', 'RA', 'OP', 'USR061', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000014', 'C00017', '2023-09-18', 'THB', 31.26865, 33369.74, '0030', '2025-07-30', '1000', '10', '02', 'FD', 'OP', 'USR056', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000015', 'C00015', '2025-11-18', 'THB', 4.51691, 33506.28, '0030', '2026-09-06', '1000', '20', '02', 'FD', 'OP', 'USR079', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000016', 'C00010', '2024-10-20', 'THB', 14.77172, 28223.96, '0002', '2026-11-11', '1000', '10', '01', 'OR', 'CL', 'USR096', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000017', 'C00004', '2023-01-25', 'EUR', 17.93283, 40197.34, '0001', '2026-03-22', '1000', '20', '02', 'FD', 'CL', 'USR050', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000018', 'C00012', '2023-11-26', 'THB', 14.86708, 34023.46, '0030', '2024-02-25', '1100', '10', '02', 'FD', 'OP', 'USR047', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000019', 'C00003', '2025-07-12', 'EUR', 31.28198, 92066.12, '0030', '2025-04-19', '1100', '20', '02', 'RA', 'OP', 'USR026', '2025-06-06');
INSERT INTO sd_sales_orders (sales_order, customer_id, order_date, currency, exchange_rate, total_amount, payment_terms, requested_delivery_date, sales_org, distribution_channel, division, order_type, status, created_by, created_date) VALUES ('SO000020', 'C00013', '2025-08-25', 'USD', 9.90474, 84985.88, '0030', '2026-05-30', '1100', '10', '01', 'OR', 'CL', 'USR052', '2025-06-06');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000006', '000001', 'MAT000020', 110.745, 'KG', 849.72, 94102.24, '2026-01-22', '1000', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000019', '000002', 'MAT000002', 700.478, 'L', 681.71, 477522.86, '2024-09-09', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000015', '000003', 'MAT000005', 275.834, 'EA', 413.06, 113935.99, '2024-04-10', '1100', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000007', '000004', 'MAT000019', 745.483, 'L', 333.49, 248611.13, '2026-09-04', '1100', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000007', '000005', 'MAT000018', 7.121, 'L', 808.65, 5758.40, '2026-08-25', '1000', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000011', '000006', 'MAT000013', 539.175, 'L', 359.68, 193930.46, '2025-08-30', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000002', '000007', 'MAT000010', 995.108, 'L', 212.56, 211520.16, '2026-09-07', '1000', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000017', '000008', 'MAT000018', 593.071, 'EA', 838.56, 497325.62, '2026-12-09', '1100', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000001', '000009', 'MAT000016', 221.515, 'L', 288.34, 63871.64, '2024-07-27', '1100', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000009', '000010', 'MAT000015', 517.085, 'KG', 857.87, 443591.71, '2026-05-16', '1100', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000008', '000011', 'MAT000004', 389.724, 'KG', 773.46, 301435.93, '2025-11-10', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000004', '000012', 'MAT000005', 513.313, 'EA', 548.70, 281654.84, '2025-06-27', '1000', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000015', '000013', 'MAT000013', 120.871, 'EA', 544.67, 65834.81, '2026-10-15', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000019', '000014', 'MAT000002', 293.393, 'KG', 755.31, 221602.67, '2025-04-06', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000010', '000015', 'MAT000016', 833.369, 'L', 610.41, 508696.77, '2025-12-12', '1000', '0002');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000012', '000016', 'MAT000002', 907.059, 'EA', 194.88, 176767.66, '2025-07-22', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000011', '000017', 'MAT000006', 88.954, 'EA', 685.54, 60981.53, '2024-05-10', '1000', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000006', '000018', 'MAT000005', 378.547, 'L', 941.70, 356477.71, '2026-03-18', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000014', '000019', 'MAT000003', 176.077, 'KG', 770.29, 135630.35, '2025-11-05', '1100', '0001');
INSERT INTO sd_so_items (sales_order, item_number, material_id, quantity, unit, price, amount, requested_delivery_date, plant, storage_location) VALUES ('SO000004', '000020', 'MAT000010', 188.826, 'L', 236.14, 44589.37, '2026-05-23', '1000', '0001');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000001', 'SO000018', 'C00002', '2024-01-20', 'EUR', 94044.23, 6583.10, 100627.33, 'S1', 'OP', 'USR090', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000002', 'SO000010', 'C00015', '2023-07-18', 'THB', 19894.49, 1392.61, 21287.10, 'S1', 'OP', 'USR096', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000003', 'SO000005', 'C00015', '2023-12-04', 'THB', 55377.45, 3876.42, 59253.87, 'F2', 'OP', 'USR066', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000004', 'SO000012', 'C00003', '2025-05-12', 'THB', 74101.31, 5187.09, 79288.40, 'F2', 'CL', 'USR048', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000005', 'SO000017', 'C00015', '2024-06-11', 'THB', 10722.39, 750.57, 11472.96, 'F2', 'OP', 'USR039', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000006', 'SO000014', 'C00007', '2023-11-23', 'USD', 65793.13, 4605.52, 70398.65, 'S1', 'OP', 'USR079', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000007', 'SO000012', 'C00007', '2025-01-30', 'EUR', 25123.24, 1758.63, 26881.87, 'F2', 'OP', 'USR089', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000008', 'SO000010', 'C00017', '2025-10-27', 'CNY', 49746.96, 3482.29, 53229.25, 'F2', 'OP', 'USR043', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000009', 'SO000012', 'C00018', '2025-11-15', 'CNY', 46555.78, 3258.90, 49814.68, 'F2', 'OP', 'USR098', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000010', 'SO000011', 'C00013', '2023-11-03', 'USD', 19038.59, 1332.70, 20371.29, 'F2', 'CL', 'USR094', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000011', 'SO000001', 'C00015', '2023-11-30', 'EUR', 7313.83, 511.97, 7825.80, 'F2', 'OP', 'USR026', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000012', 'SO000013', 'C00014', '2024-07-05', 'USD', 59804.16, 4186.29, 63990.45, 'F2', 'OP', 'USR024', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000013', 'SO000010', 'C00011', '2024-08-24', 'EUR', 99785.25, 6984.97, 106770.22, 'F2', 'OP', 'USR032', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000014', 'SO000017', 'C00003', '2023-06-25', 'THB', 10355.31, 724.87, 11080.18, 'F2', 'OP', 'USR026', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000015', 'SO000009', 'C00002', '2024-09-20', 'USD', 99967.32, 6997.71, 106965.03, 'F2', 'OP', 'USR014', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000016', 'SO000004', 'C00001', '2023-02-12', 'EUR', 9574.91, 670.24, 10245.15, 'S1', 'CL', 'USR086', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000017', 'SO000014', 'C00015', '2023-08-17', 'EUR', 4255.89, 297.91, 4553.80, 'S1', 'CL', 'USR039', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000018', 'SO000014', 'C00006', '2023-09-16', 'EUR', 97656.90, 6835.98, 104492.88, 'S1', 'OP', 'USR080', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000019', 'SO000002', 'C00015', '2023-06-01', 'CNY', 9940.27, 695.82, 10636.09, 'F2', 'CL', 'USR045', '2025-06-06');
INSERT INTO sd_billing (billing_doc, sales_order, customer_id, billing_date, currency, total_amount, tax_amount, net_amount, billing_type, status, created_by, created_date) VALUES ('B000020', 'SO000004', 'C00006', '2025-10-21', 'USD', 60315.49, 4222.08, 64537.57, 'F2', 'OP', 'USR011', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000001', 'MAT000016', '1100', 'PP01', 93.064, 'KG', '2025-02-16', '2025-03-15', '2025-02-17', '2025-03-16', 'REL', 'USR002', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000002', 'MAT000005', '1000', 'PP01', 211.984, 'L', '2024-04-14', '2024-04-30', '2024-04-15', '2024-04-30', 'TECO', 'USR009', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000003', 'MAT000019', '1000', 'PP02', 791.877, 'KG', '2025-05-16', '2025-06-06', '2025-05-17', '2025-06-06', 'CLSD', 'USR006', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000004', 'MAT000004', '1100', 'PP01', 919.401, 'KG', '2025-02-21', '2025-03-06', '2025-02-23', '2025-03-07', 'TECO', 'USR065', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000005', 'MAT000019', '1100', 'PP02', 898.041, 'KG', '2024-02-07', '2024-02-24', '2024-02-09', '2024-02-25', 'CLSD', 'USR032', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000006', 'MAT000010', '1000', 'PP01', 925.912, 'EA', '2024-05-30', '2024-06-10', '2024-05-31', '2024-06-10', 'TECO', 'USR018', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000007', 'MAT000017', '1100', 'PP02', 203.654, 'EA', '2023-08-15', '2023-09-03', '2023-08-15', '2023-09-03', 'REL', 'USR032', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000008', 'MAT000004', '1000', 'PP02', 315.258, 'EA', '2023-05-17', '2023-06-05', '2023-05-19', '2023-06-06', 'REL', 'USR067', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000009', 'MAT000011', '1100', 'PP02', 982.613, 'KG', '2025-10-10', '2025-11-03', '2025-10-10', '2025-11-03', 'CLSD', 'USR041', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000010', 'MAT000001', '1100', 'PP01', 741.926, 'L', '2025-01-18', '2025-02-15', '2025-01-19', '2025-02-15', 'TECO', 'USR068', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000011', 'MAT000008', '1100', 'PP02', 626.664, 'KG', '2023-08-26', '2023-09-22', '2023-08-27', '2023-09-22', 'REL', 'USR045', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000012', 'MAT000010', '1100', 'PP02', 780.215, 'EA', '2023-06-03', '2023-06-20', '2023-06-03', '2023-06-20', 'REL', 'USR083', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000013', 'MAT000015', '1100', 'PP02', 763.770, 'EA', '2023-06-26', '2023-07-02', '2023-06-28', '2023-07-02', 'TECO', 'USR036', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000014', 'MAT000016', '1100', 'PP02', 673.601, 'EA', '2023-06-17', '2023-06-26', '2023-06-19', '2023-06-28', 'REL', 'USR020', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000015', 'MAT000011', '1000', 'PP02', 219.849, 'EA', '2024-08-08', '2024-09-04', '2024-08-08', '2024-09-05', 'CLSD', 'USR072', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000016', 'MAT000014', '1000', 'PP01', 569.888, 'KG', '2024-05-31', '2024-06-26', '2024-06-01', '2024-06-28', 'TECO', 'USR073', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000017', 'MAT000007', '1100', 'PP01', 341.464, 'KG', '2023-02-27', '2023-03-29', '2023-03-01', '2023-03-29', 'TECO', 'USR024', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000018', 'MAT000004', '1100', 'PP01', 119.293, 'EA', '2023-12-31', '2024-01-21', '2023-12-31', '2024-01-22', 'REL', 'USR075', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000019', 'MAT000009', '1100', 'PP02', 979.609, 'KG', '2024-10-29', '2024-11-28', '2024-10-31', '2024-11-29', 'CLSD', 'USR099', '2025-06-06');
INSERT INTO pp_production_orders (production_order, material_id, plant, order_type, quantity, unit, start_date, finish_date, actual_start_date, actual_finish_date, status, created_by, created_date) VALUES ('PR000020', 'MAT000005', '1000', 'PP02', 447.102, 'EA', '2024-08-27', '2024-09-21', '2024-08-27', '2024-09-22', 'CLSD', 'USR034', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0001', 'WorkCenter 1', '1100', 'MACH', 23.056, 'H', 'CC0001', 'BTY', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0002', 'WorkCenter 2', '1000', 'LABOR', 21.940, 'MIN', 'CC0002', 'GQA', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0003', 'WorkCenter 3', '1000', 'MACH', 13.495, 'H', 'CC0003', 'WPN', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0004', 'WorkCenter 4', '1000', 'MACH', 9.245, 'H', 'CC0004', 'JPI', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0005', 'WorkCenter 5', '1000', 'LABOR', 6.618, 'H', 'CC0005', 'GMT', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0006', 'WorkCenter 6', '1000', 'MACH', 11.819, 'MIN', 'CC0006', 'BHL', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0007', 'WorkCenter 7', '1000', 'LABOR', 19.893, 'MIN', 'CC0007', 'FLL', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0008', 'WorkCenter 8', '1100', 'MACH', 2.390, 'H', 'CC0008', 'LWR', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0009', 'WorkCenter 9', '1100', 'LABOR', 6.776, 'H', 'CC0009', 'YTA', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0010', 'WorkCenter 10', '1100', 'LABOR', 11.199, 'H', 'CC0010', 'RCM', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0011', 'WorkCenter 11', '1100', 'LABOR', 23.876, 'H', 'CC0011', 'BUE', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0012', 'WorkCenter 12', '1000', 'MACH', 17.271, 'MIN', 'CC0012', 'AKC', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0013', 'WorkCenter 13', '1000', 'LABOR', 20.250, 'MIN', 'CC0013', 'JKA', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0014', 'WorkCenter 14', '1000', 'MACH', 4.553, 'H', 'CC0014', 'AUE', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0015', 'WorkCenter 15', '1000', 'MACH', 18.805, 'H', 'CC0015', 'WRD', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0016', 'WorkCenter 16', '1000', 'LABOR', 12.777, 'H', 'CC0016', 'DHG', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0017', 'WorkCenter 17', '1000', 'MACH', 2.510, 'H', 'CC0017', 'TGZ', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0018', 'WorkCenter 18', '1000', 'LABOR', 19.480, 'MIN', 'CC0018', 'BLA', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0019', 'WorkCenter 19', '1100', 'LABOR', 7.598, 'MIN', 'CC0019', 'HPL', '2025-06-06');
INSERT INTO pp_work_centers (work_center_id, work_center_name, plant, capacity_category, standard_capacity, capacity_unit, cost_center, person_responsible, created_date) VALUES ('WC0020', 'WorkCenter 20', '1100', 'LABOR', 18.651, 'H', 'CC0020', 'XYP', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0001', 'MAT000019', '1000', '2', '04', 499.527, 'KG', 'CR', '2023-07-06', '2024-07-05', 'USR006', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0002', 'MAT000003', '1100', '3', '04', 287.876, 'KG', 'RE', '2024-07-29', '2025-07-29', 'USR013', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0003', 'MAT000005', '1100', '1', '05', 12.683, 'EA', 'CR', '2024-05-05', '2025-05-05', 'USR075', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0004', 'MAT000018', '1100', '3', '05', 687.028, 'L', 'CR', '2023-09-06', '2024-09-05', 'USR068', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0005', 'MAT000003', '1100', '1', '04', 807.699, 'KG', 'RE', '2023-10-29', '2024-10-28', 'USR050', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0006', 'MAT000005', '1100', '3', '05', 815.904, 'EA', 'RE', '2023-02-15', '2024-02-15', 'USR072', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0007', 'MAT000017', '1100', '3', '05', 944.595, 'EA', 'CR', '2024-08-04', '2025-08-04', 'USR002', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0008', 'MAT000019', '1000', '1', '01', 955.583, 'EA', 'CR', '2023-12-10', '2024-12-09', 'USR070', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0009', 'MAT000012', '1100', '3', '05', 956.976, 'EA', 'RE', '2024-06-25', '2025-06-25', 'USR026', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0010', 'MAT000005', '1100', '1', '01', 3.735, 'EA', 'CR', '2024-06-08', '2025-06-08', 'USR042', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0011', 'MAT000001', '1000', '3', '05', 632.143, 'L', 'CR', '2023-03-30', '2024-03-29', 'USR077', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0012', 'MAT000016', '1100', '1', '02', 266.804, 'EA', 'CR', '2023-07-22', '2024-07-21', 'USR027', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0013', 'MAT000019', '1100', '2', '04', 99.307, 'EA', 'RE', '2024-07-05', '2025-07-05', 'USR023', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0014', 'MAT000018', '1000', '3', '04', 589.883, 'L', 'RE', '2024-03-31', '2025-03-31', 'USR089', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0015', 'MAT000007', '1000', '1', '01', 933.870, 'L', 'CR', '2023-05-15', '2024-05-14', 'USR010', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0016', 'MAT000018', '1100', '3', '01', 492.275, 'KG', 'RE', '2023-06-26', '2024-06-25', 'USR060', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0017', 'MAT000015', '1000', '3', '02', 296.202, 'KG', 'RE', '2023-01-04', '2024-01-04', 'USR008', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0018', 'MAT000020', '1000', '2', '01', 885.710, 'EA', 'CR', '2023-06-19', '2024-06-18', 'USR081', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0019', 'MAT000004', '1000', '1', '05', 258.319, 'EA', 'CR', '2024-04-17', '2025-04-17', 'USR024', '2025-06-06');
INSERT INTO pp_bom_header (bom_id, material_id, plant, bom_usage, alternative_bom, base_quantity, base_unit, status, valid_from, valid_to, created_by, created_date) VALUES ('BOM0020', 'MAT000009', '1000', '3', '05', 544.482, 'L', 'CR', '2024-03-02', '2025-03-02', 'USR028', '2025-06-06');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0018', '0001', 'MAT000017', 73.387, 'EA', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0017', '0002', 'MAT000005', 70.132, 'L', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0015', '0003', 'MAT000014', 70.990, 'EA', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0010', '0004', 'MAT000004', 30.634, 'KG', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0016', '0005', 'MAT000010', 89.240, 'L', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0013', '0006', 'MAT000014', 86.170, 'KG', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0007', '0007', 'MAT000003', 28.624, 'KG', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0020', '0008', 'MAT000012', 57.682, 'KG', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0010', '0009', 'MAT000001', 86.157, 'EA', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0012', '0010', 'MAT000015', 67.201, 'L', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0004', '0011', 'MAT000009', 62.439, 'EA', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0012', '0012', 'MAT000018', 70.144, 'EA', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0011', '0013', 'MAT000011', 21.065, 'EA', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0003', '0014', 'MAT000020', 71.120, 'KG', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0008', '0015', 'MAT000010', 44.848, 'KG', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0019', '0016', 'MAT000008', 66.989, 'EA', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0012', '0017', 'MAT000018', 90.187, 'EA', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0003', '0018', 'MAT000016', 69.792, 'L', 'N');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0002', '0019', 'MAT000005', 85.862, 'KG', 'L');
INSERT INTO pp_bom_items (bom_id, item_number, component_material, component_quantity, component_unit, item_category) VALUES ('BOM0004', '0020', 'MAT000018', 9.753, 'KG', 'N');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000001', 'Account 1', '2000', 'A', FALSE, FALSE, 'USD', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000002', 'Account 2', '2000', 'Q', TRUE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000003', 'Account 3', '2000', 'L', FALSE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000004', 'Account 4', '2000', 'A', TRUE, TRUE, 'CNY', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000005', 'Account 5', '2000', 'P', TRUE, FALSE, 'EUR', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000006', 'Account 6', '3000', 'A', FALSE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000007', 'Account 7', '2000', 'P', TRUE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000008', 'Account 8', '3000', 'L', FALSE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000009', 'Account 9', '3000', 'P', FALSE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000010', 'Account 10', '2000', 'P', TRUE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000011', 'Account 11', '1000', 'L', FALSE, FALSE, 'CNY', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000012', 'Account 12', '2000', 'A', TRUE, TRUE, 'EUR', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000013', 'Account 13', '3000', 'P', TRUE, TRUE, 'USD', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000014', 'Account 14', '1000', 'A', TRUE, TRUE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000015', 'Account 15', '1000', 'P', FALSE, TRUE, 'CNY', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000016', 'Account 16', '2000', 'Q', TRUE, FALSE, 'THB', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000017', 'Account 17', '2000', 'L', FALSE, TRUE, 'CNY', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000018', 'Account 18', '2000', 'A', FALSE, FALSE, 'CNY', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000019', 'Account 19', '1000', 'Q', FALSE, TRUE, 'USD', '2025-06-06');
INSERT INTO fi_chart_accounts (account_number, account_name, account_group, account_type, balance_sheet_account, pl_account, currency, created_date) VALUES ('000020', 'Account 20', '3000', 'Q', TRUE, FALSE, 'USD', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0001', 'CostCenter 1', 'USR029', '1000', 'A001', 'S1', 'HR042', '2023-06-29', '2028-06-27', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0002', 'CostCenter 2', 'USR005', '1100', 'A001', 'S1', 'HR041', '2023-11-18', '2028-11-16', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0003', 'CostCenter 3', 'USR093', '1000', 'A001', 'S2', 'HR062', '2024-01-29', '2029-01-27', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0004', 'CostCenter 4', 'USR047', '1000', 'A002', 'S1', 'HR021', '2024-08-25', '2029-08-24', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0005', 'CostCenter 5', 'USR072', '1100', 'A002', 'S2', 'HR090', '2023-11-16', '2028-11-14', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0006', 'CostCenter 6', 'USR046', '1100', 'A002', 'S2', 'HR077', '2023-01-07', '2028-01-06', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0007', 'CostCenter 7', 'USR014', '1000', 'A001', 'S1', 'HR093', '2024-09-10', '2029-09-09', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0008', 'CostCenter 8', 'USR095', '1100', 'A001', 'S1', 'HR072', '2023-05-17', '2028-05-15', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0009', 'CostCenter 9', 'USR034', '1000', 'A002', 'S2', 'HR060', '2024-01-26', '2029-01-24', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0010', 'CostCenter 10', 'USR012', '1000', 'A001', 'S2', 'HR091', '2023-11-05', '2028-11-03', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0011', 'CostCenter 11', 'USR088', '1100', 'A002', 'S1', 'HR031', '2024-02-04', '2029-02-02', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0012', 'CostCenter 12', 'USR099', '1000', 'A001', 'S1', 'HR016', '2024-12-11', '2029-12-10', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0013', 'CostCenter 13', 'USR081', '1000', 'A002', 'S1', 'HR075', '2024-10-16', '2029-10-15', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0014', 'CostCenter 14', 'USR019', '1100', 'A002', 'S2', 'HR079', '2024-11-20', '2029-11-19', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0015', 'CostCenter 15', 'USR024', '1000', 'A001', 'S2', 'HR053', '2024-11-21', '2029-11-20', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0016', 'CostCenter 16', 'USR061', '1000', 'A002', 'S1', 'HR022', '2023-07-26', '2028-07-24', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0017', 'CostCenter 17', 'USR042', '1000', 'A002', 'S1', 'HR055', '2023-08-17', '2028-08-15', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0018', 'CostCenter 18', 'USR056', '1100', 'A001', 'S1', 'HR062', '2023-04-16', '2028-04-14', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0019', 'CostCenter 19', 'USR016', '1000', 'A001', 'S1', 'HR056', '2024-11-04', '2029-11-03', '2025-06-06');
INSERT INTO co_cost_centers (cost_center, cost_center_name, responsible_person, company_code, controlling_area, cost_center_category, hierarchy_area, valid_from, valid_to, created_date) VALUES ('CC0020', 'CostCenter 20', 'USR009', '1100', 'A002', 'S2', 'HR033', '2024-04-04', '2029-04-03', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000001', '1100', '2025', '001', '000007', '2024-03-30', '2024-03-30', 'SA', 'MRAWELKM', 599.45, 1337.82, 'USD', 'CC0001', '50', 'USR068', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000002', '1100', '2025', '002', '000002', '2025-10-17', '2025-10-17', 'KR', 'TUVHMWPK', 305.43, 7305.17, 'THB', 'CC0016', '50', 'USR099', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000003', '1100', '2025', '003', '000017', '2025-05-18', '2025-05-18', 'KR', 'TOLBQGLO', 8217.91, 1635.22, 'THB', 'CC0012', '50', 'USR094', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000004', '1100', '2025', '004', '000019', '2025-08-28', '2025-08-28', 'DR', 'GXAVIEAZ', 1791.33, 2005.26, 'CNY', 'CC0005', '40', 'USR044', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000005', '1100', '2025', '005', '000004', '2023-04-16', '2023-04-16', 'KR', 'ECCEJDGB', 7342.25, 432.06, 'USD', 'CC0015', '50', 'USR052', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000006', '1100', '2025', '006', '000017', '2023-04-05', '2023-04-05', 'DR', 'RMESBCCU', 2833.40, 3860.81, 'CNY', 'CC0008', '40', 'USR067', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000007', '1000', '2025', '007', '000003', '2025-08-26', '2025-08-26', 'SA', 'GEXZZLAV', 4578.54, 5252.38, 'USD', 'CC0007', '50', 'USR046', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000008', '1100', '2025', '008', '000013', '2023-05-17', '2023-05-17', 'SA', 'HTIBRFZH', 9280.01, 4904.57, 'EUR', 'CC0006', '50', 'USR030', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000009', '1100', '2025', '009', '000017', '2023-11-14', '2023-11-14', 'SA', 'PJFUUFOS', 6433.47, 1465.09, 'USD', 'CC0014', '40', 'USR063', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000010', '1000', '2025', '010', '000006', '2025-04-08', '2025-04-08', 'KR', 'JQCFGVDN', 9132.99, 3433.43, 'EUR', 'CC0016', '50', 'USR087', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000011', '1100', '2025', '011', '000012', '2024-02-15', '2024-02-15', 'SA', 'LCYRZNFH', 926.18, 9003.67, 'CNY', 'CC0015', '50', 'USR004', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000012', '1100', '2025', '012', '000002', '2023-07-10', '2023-07-10', 'SA', 'NPTVTQAJ', 5327.61, 2698.75, 'THB', 'CC0001', '40', 'USR050', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000013', '1100', '2025', '013', '000004', '2023-01-10', '2023-01-10', 'SA', 'QEXDFSOU', 4855.27, 818.58, 'USD', 'CC0001', '40', 'USR010', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000014', '1100', '2025', '014', '000002', '2025-09-03', '2025-09-03', 'KR', 'XEJRJKZH', 1598.52, 134.41, 'EUR', 'CC0007', '50', 'USR055', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000015', '1100', '2025', '015', '000005', '2024-10-18', '2024-10-18', 'SA', 'CQSZDMRU', 3716.95, 4780.53, 'EUR', 'CC0014', '40', 'USR068', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000016', '1000', '2025', '016', '000009', '2024-05-25', '2024-05-25', 'KR', 'IUTYMMQL', 6324.98, 5619.87, 'USD', 'CC0013', '50', 'USR095', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000017', '1000', '2025', '017', '000003', '2023-11-24', '2023-11-24', 'SA', 'HJVIKQWN', 9755.67, 13.52, 'THB', 'CC0020', '40', 'USR075', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000018', '1000', '2025', '018', '000007', '2025-06-16', '2025-06-16', 'SA', 'QGXIOXYS', 3149.70, 1367.74, 'CNY', 'CC0012', '40', 'USR079', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000019', '1100', '2025', '019', '000009', '2024-03-21', '2024-03-21', 'KR', 'LHVSQEUL', 9415.47, 9399.19, 'CNY', 'CC0009', '50', 'USR064', '2025-06-06');
INSERT INTO fi_general_ledger (document_number, company_code, fiscal_year, line_item, account_number, posting_date, document_date, document_type, reference, debit_amount, credit_amount, currency, cost_center, posting_key, created_by, created_date) VALUES ('D000020', '1100', '2025', '020', '000008', '2024-02-08', '2024-02-08', 'DR', 'BZAOPPVS', 5719.95, 7475.12, 'CNY', 'CC0006', '50', 'USR042', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00001', '1100', '2025', '001', 'V00020', '2024-02-08', '2024-03-09', 69625.58, 'USD', '0002', 'EISNDQUV', 'O', 'USR084', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00002', '1000', '2025', '002', 'V00001', '2025-06-01', '2025-07-01', 59115.09, 'USD', '0002', 'TSTIRHBN', 'O', 'USR085', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00003', '1100', '2025', '003', 'V00012', '2024-09-23', '2024-10-23', 44947.41, 'EUR', '0001', 'ONMBZFTI', 'O', 'USR037', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00004', '1000', '2025', '004', 'V00007', '2023-09-30', '2023-10-30', 16817.83, 'EUR', '0030', 'NOJKHRMZ', 'O', 'USR075', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00005', '1100', '2025', '005', 'V00007', '2023-11-07', '2023-12-07', 74721.70, 'USD', '0001', 'ADDAPKOP', 'O', 'USR075', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00006', '1100', '2025', '006', 'V00006', '2023-12-23', '2024-01-22', 13853.16, 'USD', '0030', 'YHWRLZHW', 'C', 'USR056', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00007', '1000', '2025', '007', 'V00012', '2025-03-10', '2025-04-09', 28652.20, 'CNY', '0002', 'FWVNHQZE', 'C', 'USR054', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00008', '1000', '2025', '008', 'V00001', '2025-06-30', '2025-07-30', 75741.10, 'CNY', '0001', 'IKLYBXDB', 'C', 'USR091', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00009', '1100', '2025', '009', 'V00008', '2023-11-07', '2023-12-07', 68646.83, 'USD', '0001', 'FJUVZWQU', 'O', 'USR033', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00010', '1100', '2025', '010', 'V00007', '2025-07-17', '2025-08-16', 25139.28, 'THB', '0001', 'TROTLDJU', 'C', 'USR040', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00011', '1000', '2025', '011', 'V00009', '2025-11-21', '2025-12-21', 36740.36, 'EUR', '0001', 'KAJUPQLB', 'O', 'USR085', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00012', '1000', '2025', '012', 'V00016', '2023-11-11', '2023-12-11', 69652.82, 'EUR', '0001', 'UXBYCZAY', 'C', 'USR029', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00013', '1000', '2025', '013', 'V00006', '2025-03-26', '2025-04-25', 26120.93, 'CNY', '0030', 'NYYPTPFM', 'C', 'USR021', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00014', '1000', '2025', '014', 'V00016', '2023-06-25', '2023-07-25', 6462.48, 'EUR', '0001', 'BJJJALJB', 'C', 'USR078', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00015', '1000', '2025', '015', 'V00015', '2025-05-29', '2025-06-28', 89755.04, 'THB', '0001', 'WCHYQOOL', 'C', 'USR097', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00016', '1000', '2025', '016', 'V00019', '2024-10-15', '2024-11-14', 17757.19, 'EUR', '0002', 'UGCEGIWW', 'C', 'USR052', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00017', '1100', '2025', '017', 'V00019', '2023-03-31', '2023-04-30', 87037.02, 'THB', '0001', 'WYWHRKCM', 'O', 'USR041', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00018', '1100', '2025', '018', 'V00015', '2025-07-02', '2025-08-01', 37174.15, 'EUR', '0001', 'LLSVOJQP', 'C', 'USR088', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00019', '1000', '2025', '019', 'V00008', '2023-04-22', '2023-05-22', 97957.49, 'CNY', '0001', 'SIWNREXO', 'C', 'USR034', '2025-06-06');
INSERT INTO fi_accounts_payable (document_number, company_code, fiscal_year, line_item, vendor_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AP00020', '1000', '2025', '020', 'V00003', '2023-08-28', '2023-09-27', 60311.55, 'USD', '0001', 'EBDJMPJT', 'C', 'USR085', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00001', '1100', '2025', '001', 'C00006', '2023-02-09', '2023-03-11', 64433.64, 'USD', '0002', 'ERRUXOUA', 'O', 'USR036', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00002', '1100', '2025', '002', 'C00008', '2025-05-18', '2025-06-17', 11289.86, 'CNY', '0001', 'RIUJKMJV', 'O', 'USR049', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00003', '1100', '2025', '003', 'C00014', '2025-06-04', '2025-07-04', 3458.87, 'CNY', '0002', 'WHWKTDPI', 'C', 'USR067', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00004', '1000', '2025', '004', 'C00020', '2023-09-23', '2023-10-23', 18416.52, 'THB', '0030', 'GMRVWCWE', 'O', 'USR057', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00005', '1100', '2025', '005', 'C00011', '2025-06-08', '2025-07-08', 31620.34, 'THB', '0030', 'MRLKSFUA', 'O', 'USR011', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00006', '1100', '2025', '006', 'C00017', '2024-03-03', '2024-04-02', 44402.30, 'EUR', '0002', 'AKWYZYHI', 'C', 'USR012', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00007', '1100', '2025', '007', 'C00017', '2023-04-29', '2023-05-29', 59571.46, 'EUR', '0030', 'HVTAEGFO', 'O', 'USR013', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00008', '1000', '2025', '008', 'C00005', '2024-07-29', '2024-08-28', 19429.71, 'CNY', '0001', 'PNKNRHCR', 'O', 'USR093', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00009', '1100', '2025', '009', 'C00008', '2025-12-26', '2026-01-25', 64929.73, 'EUR', '0001', 'VPGEDJVM', 'O', 'USR070', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00010', '1000', '2025', '010', 'C00004', '2024-07-07', '2024-08-06', 64334.01, 'EUR', '0030', 'TZQTQFKU', 'C', 'USR072', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00011', '1000', '2025', '011', 'C00018', '2024-12-01', '2024-12-31', 8050.82, 'THB', '0001', 'SOCYRGZX', 'C', 'USR095', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00012', '1000', '2025', '012', 'C00012', '2024-07-14', '2024-08-13', 49610.36, 'THB', '0001', 'DOPIXOBO', 'O', 'USR071', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00013', '1000', '2025', '013', 'C00015', '2025-04-01', '2025-05-01', 80003.82, 'CNY', '0030', 'CBBVQYYN', 'O', 'USR003', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00014', '1000', '2025', '014', 'C00010', '2025-03-07', '2025-04-06', 67936.04, 'THB', '0002', 'TXEPOUSS', 'C', 'USR072', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00015', '1100', '2025', '015', 'C00017', '2024-01-10', '2024-02-09', 80079.25, 'CNY', '0002', 'XPHYSWOQ', 'C', 'USR019', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00016', '1100', '2025', '016', 'C00011', '2023-06-06', '2023-07-06', 58257.59, 'EUR', '0001', 'DIYSLAQT', 'O', 'USR094', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00017', '1000', '2025', '017', 'C00010', '2023-06-19', '2023-07-19', 43037.05, 'USD', '0030', 'KGZLPJAV', 'C', 'USR092', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00018', '1100', '2025', '018', 'C00001', '2024-04-24', '2024-05-24', 5510.13, 'THB', '0002', 'ANKYIZGV', 'O', 'USR087', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00019', '1100', '2025', '019', 'C00002', '2023-09-09', '2023-10-09', 72353.42, 'USD', '0030', 'TXWVCSKK', 'O', 'USR013', '2025-06-06');
INSERT INTO fi_accounts_receivable (document_number, company_code, fiscal_year, line_item, customer_id, posting_date, due_date, amount, currency, payment_terms, reference, status, created_by, created_date) VALUES ('AR00020', '1100', '2025', '020', 'C00017', '2023-04-27', '2023-05-27', 22203.42, 'USD', '0001', 'FMYZNRZE', 'C', 'USR099', '2025-06-06');
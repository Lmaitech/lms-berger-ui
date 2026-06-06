-- =====================================================
-- MIGRATION: Add Estimate Mode & Type Metadata Columns
-- =====================================================

BEGIN;

-- 1. Alter estimates table to support Mode and Type tracking
ALTER TABLE estimates ADD COLUMN IF NOT EXISTS estimate_mode VARCHAR(30) DEFAULT 'SUPPLY';
ALTER TABLE estimates ADD COLUMN IF NOT EXISTS estimate_type VARCHAR(30) DEFAULT 'VALUE';

-- 2. Drop and recreate estimate_details_view to include these columns
DROP VIEW IF EXISTS estimate_details_view CASCADE;
CREATE VIEW estimate_details_view AS
SELECT 
    e.estimate_id,
    e.lead_id,
    e.painter_id,
    e.estimate_version,
    e.estimate_mode,
    e.estimate_type,
    e.material_total,
    e.labour_cost,
    e.discount,
    e.grand_total,
    e.submitted_at,
    ei.estimate_item_id,
    ei.product_id,
    ei.quantity,
    ei.rate,
    ei.line_total,
    p.sku_code,
    p.product_name,
    p.category,
    p.unit
FROM estimates e
JOIN estimate_items ei ON e.estimate_id = ei.estimate_id
JOIN products p ON ei.product_id = p.product_id;

COMMIT;

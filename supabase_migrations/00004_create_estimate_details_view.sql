-- =====================================================
-- MIGRATION: Create Estimate Details Consolidated View
-- =====================================================

BEGIN;

CREATE OR REPLACE VIEW estimate_details_view AS
SELECT 
    e.estimate_id,
    e.lead_id,
    e.painter_id,
    e.estimate_version,
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

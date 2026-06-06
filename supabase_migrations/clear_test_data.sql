-- =====================================================
-- SCRIPT: Clear Test Data
-- Description: Deletes all data from transactional tables.
-- Preserves master data: users, lost_reasons, products, and retailer_painter_mapping.
-- =====================================================

BEGIN;

-- Defer constraints to prevent foreign key errors during truncation
SET CONSTRAINTS ALL DEFERRED;

TRUNCATE TABLE 
    estimate_items, 
    estimates, 
    followups, 
    site_visits, 
    lead_assignment_history, 
    lead_status_history, 
    notifications, 
    painter_performance, 
    leads 
RESTART IDENTITY CASCADE;

COMMIT;

-- =====================================================
-- MIGRATION: Add Customer Role & Unified Open Leads View
-- =====================================================

BEGIN;

-- 1. Safely alter check constraint on users.user_type to include 'CUSTOMER'
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT conname 
        FROM pg_constraint 
        WHERE conrelid = 'users'::regclass 
          AND contype = 'c' 
          AND pg_get_constraintdef(oid) LIKE '%user_type%'
    LOOP
        EXECUTE 'ALTER TABLE users DROP CONSTRAINT ' || quote_ident(r.conname);
    END LOOP;
END $$;

ALTER TABLE users ADD CONSTRAINT users_user_type_check 
    CHECK (user_type IN ('RETAILER', 'PAINTER', 'DSE', 'DSO', 'ADMIN', 'CUSTOMER'));

-- 2. Create the unified user open leads view
CREATE OR REPLACE VIEW user_open_leads_view AS
SELECT 
    u.id AS user_id,
    u.user_type,
    u.name AS user_name,
    u.mobile AS user_mobile,
    l.lead_id,
    l.retailer_id,
    l.current_painter_id,
    l.site_owner_name,
    l.site_owner_mobile,
    l.address_line1,
    l.address_line2,
    l.town,
    l.state,
    l.pincode,
    l.carpet_area,
    l.site_type,
    l.budget_range,
    l.expected_start_date,
    l.visit_date,
    l.visit_time,
    l.current_status,
    l.registered_latitude,
    l.registered_longitude,
    l.latest_estimate_id,
    l.next_followup_date,
    l.lost_reason_id,
    l.created_at AS lead_created_at,
    l.updated_at AS lead_updated_at,
    l.closed_at AS lead_closed_at,
    
    -- Retailer Info
    ret.name AS retailer_name,
    ret.mobile AS retailer_mobile,
    
    -- Painter Info
    pt.name AS painter_name,
    pt.mobile AS painter_mobile
FROM users u
LEFT JOIN leads l ON (
    (u.user_type = 'RETAILER' AND l.retailer_id = u.id AND l.current_status NOT IN ('WON', 'LOST')) OR
    (u.user_type = 'PAINTER' AND l.current_painter_id = u.id AND l.current_status NOT IN ('WON', 'LOST', 'ASSIGNED')) OR
    (u.user_type = 'CUSTOMER' AND l.site_owner_mobile = u.mobile AND l.current_status NOT IN ('WON', 'LOST'))
)
LEFT JOIN users ret ON l.retailer_id = ret.id
LEFT JOIN users pt ON l.current_painter_id = pt.id
WHERE u.active = true;

-- 3. Create the lead assignment history view with painter details
CREATE OR REPLACE VIEW lead_assignment_history_view AS
SELECT 
    a.assignment_id,
    a.lead_id,
    a.painter_id,
    u.name AS painter_name,
    u.mobile AS painter_mobile,
    a.assigned_at,
    a.response_status,
    a.response_at,
    a.rejection_reason
FROM lead_assignment_history a
JOIN users u ON a.painter_id = u.id;

COMMIT;

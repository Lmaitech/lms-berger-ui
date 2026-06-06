-- =====================================================
-- MIGRATION: Add latest_visit_number to user_open_leads_view
-- =====================================================

BEGIN;

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
    pt.mobile AS painter_mobile,

    -- Latest Visit Number from site_visits
    COALESCE((SELECT MAX(sv.visit_number) FROM site_visits sv WHERE sv.lead_id = l.lead_id), 0) AS latest_visit_number
FROM users u
LEFT JOIN leads l ON (
    (u.user_type = 'RETAILER' AND l.retailer_id = u.id AND l.current_status NOT IN ('WON', 'LOST')) OR
    (u.user_type = 'PAINTER' AND l.current_painter_id = u.id AND l.current_status NOT IN ('WON', 'LOST', 'ASSIGNED')) OR
    (u.user_type = 'CUSTOMER' AND l.site_owner_mobile = u.mobile AND l.current_status NOT IN ('WON', 'LOST'))
)
LEFT JOIN users ret ON l.retailer_id = ret.id
LEFT JOIN users pt ON l.current_painter_id = pt.id
WHERE u.active = true;

COMMIT;

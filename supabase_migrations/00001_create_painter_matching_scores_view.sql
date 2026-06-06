-- =====================================================
-- MIGRATION: 00001 Create Painter Matching Scores View
-- Description: Computes auto-assignment ranking score for painters.
-- Minimizes read operations by performing joins and scores in-database.
-- =====================================================

CREATE OR REPLACE VIEW painter_matching_scores AS
SELECT 
    m.retailer_id,
    p.id AS painter_id,
    p.name AS painter_name,
    p.mobile AS painter_mobile,
    perf.allocated_sites,
    perf.accepted_sites,
    perf.won_sites,
    perf.lost_sites,
    perf.open_leads,
    perf.last_assigned_at,
    
    -- Equal Opportunity Priority (allocated_sites = 0 gets top priority)
    CASE 
        WHEN COALESCE(perf.allocated_sites, 0) = 0 THEN 1 
        ELSE 0 
    END AS is_new_priority,

    -- Acceptance Rate Calculation (Uses provisional 50.0% if sample size < 5 allocated sites)
    CASE 
        WHEN COALESCE(perf.allocated_sites, 0) < 5 THEN 50.0
        ELSE ROUND((perf.accepted_sites::numeric / perf.allocated_sites::numeric) * 100, 2)
    END AS calculated_acceptance_rate,

    -- Conversion Rate Calculation (Uses provisional 50.0% if sample size < 5 allocated sites)
    CASE 
        WHEN COALESCE(perf.allocated_sites, 0) < 5 THEN 50.0
        WHEN COALESCE(perf.accepted_sites, 0) > 0 THEN ROUND((perf.won_sites::numeric / perf.accepted_sites::numeric) * 100, 2)
        ELSE 50.0
    END AS calculated_conversion_rate,

    -- Availability Score Calculation (Uses capacity limit of 20, clamps to positive values)
    ROUND(
        GREATEST(0, (1.0 - (COALESCE(perf.open_leads, 0)::numeric / 20.0)) * 100), 
        2
    ) AS calculated_availability_score

FROM retailer_painter_mapping m
JOIN users p ON m.painter_id = p.id
LEFT JOIN painter_performance perf ON p.id = perf.painter_id
WHERE p.user_type = 'PAINTER' 
  AND p.active = true 
  AND m.active = true;

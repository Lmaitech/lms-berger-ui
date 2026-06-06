-- Migration 00006: Create user credentials, DSE-Retailer mappings, DSO-DSE mappings, and reporting views.

-- 1. Create User Credentials table (simple plaintext password check)
CREATE TABLE IF NOT EXISTS user_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index username for fast lookups
CREATE INDEX IF NOT EXISTS idx_user_credentials_username ON user_credentials (LOWER(username));

-- 2. Create DSE-Retailer Mapping table
CREATE TABLE IF NOT EXISTS dse_retailer_mapping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dse_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    retailer_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE, -- Each retailer reports to 1 DSE
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_dse_retailer_dse ON dse_retailer_mapping (dse_id);
CREATE INDEX IF NOT EXISTS idx_dse_retailer_retailer ON dse_retailer_mapping (retailer_id);

-- 3. Create DSO-DSE Mapping table
CREATE TABLE IF NOT EXISTS dso_dse_mapping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dso_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    dse_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE, -- Each DSE reports to 1 DSO
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_dso_dse_dso ON dso_dse_mapping (dso_id);
CREATE INDEX IF NOT EXISTS idx_dso_dse_dse ON dso_dse_mapping (dse_id);

-- 4. Create Unified Lead Detail Drill-down view for reporting
CREATE OR REPLACE VIEW lead_detail_drilldown_view AS
SELECT 
    -- DSO details
    dso.id AS dso_id,
    dso.name AS dso_name,
    dso.mobile AS dso_mobile,
    
    -- DSE details
    dse.id AS dse_id,
    dse.name AS dse_name,
    dse.mobile AS dse_mobile,
    
    -- Retailer details
    ret.id AS retailer_id,
    ret.name AS retailer_name,
    ret.mobile AS retailer_mobile,
    
    -- Lead details
    l.lead_id AS lead_id,
    l.site_owner_name AS site_owner_name,
    l.site_owner_mobile AS site_owner_mobile,
    l.address_line1 AS address_line1,
    l.address_line2 AS address_line2,
    l.town AS town,
    l.state AS state,
    l.pincode AS pincode,
    l.carpet_area AS carpet_area,
    l.site_type AS site_type,
    l.budget_range AS budget_range,
    l.current_status AS current_status,
    l.created_at AS lead_created_at,
    l.closed_at AS lead_closed_at,
    
    -- Painter details
    p.id AS painter_id,
    p.name AS painter_name,
    p.mobile AS painter_mobile,
    
    -- Estimate details
    e.estimate_id AS latest_estimate_id,
    e.grand_total AS latest_estimate_total,
    e.material_total AS latest_estimate_material,
    e.labour_cost AS latest_estimate_labour
FROM leads l
JOIN users ret ON l.retailer_id = ret.id AND ret.user_type = 'RETAILER'
LEFT JOIN dse_retailer_mapping drm ON ret.id = drm.retailer_id AND drm.active = true
LEFT JOIN users dse ON drm.dse_id = dse.id AND dse.user_type = 'DSE'
LEFT JOIN dso_dse_mapping ddm ON dse.id = ddm.dse_id AND ddm.active = true
LEFT JOIN users dso ON ddm.dso_id = dso.id AND dso.user_type = 'DSO'
LEFT JOIN users p ON l.current_painter_id = p.id AND p.user_type = 'PAINTER'
LEFT JOIN estimates e ON l.latest_estimate_id = e.estimate_id;

-- 5. Seed Mock Data for DSO, DSE, and mappings
INSERT INTO users (id, user_type, name, mobile, email, active)
VALUES 
    ('d5000000-0000-0000-0000-000000000000', 'DSO', 'DSO Executive', '9999999901', 'dso@berger.com', true),
    ('d5e00000-0000-0000-0000-000000000000', 'DSE', 'DSE Agent', '9999999902', 'dse@berger.com', true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    mobile = EXCLUDED.mobile,
    email = EXCLUDED.email;

INSERT INTO user_credentials (user_id, username, password)
VALUES 
    ('d5000000-0000-0000-0000-000000000000', 'dso', 'dso123'),
    ('d5e00000-0000-0000-0000-000000000000', 'dse', 'dse123')
ON CONFLICT (user_id) DO UPDATE SET
    username = EXCLUDED.username,
    password = EXCLUDED.password;

INSERT INTO dso_dse_mapping (dso_id, dse_id, active)
VALUES 
    ('d5000000-0000-0000-0000-000000000000', 'd5e00000-0000-0000-0000-000000000000', true)
ON CONFLICT (dse_id) DO UPDATE SET
    dso_id = EXCLUDED.dso_id,
    active = EXCLUDED.active;

-- Map any existing Retailers to the DSE for previewing drilldowns
INSERT INTO dse_retailer_mapping (dse_id, retailer_id, active)
SELECT 'd5e00000-0000-0000-0000-000000000000', id, true
FROM users
WHERE user_type = 'RETAILER'
ON CONFLICT (retailer_id) DO NOTHING;


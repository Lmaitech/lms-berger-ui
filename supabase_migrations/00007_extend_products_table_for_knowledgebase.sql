-- Migration 00007: Extend products table and seed Berger product knowledge base details.

-- 1. Add new columns to products table if they don't exist
ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS specifications JSONB DEFAULT '[]'::jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS segment VARCHAR(50);
ALTER TABLE products ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;

-- 2. Seed Berger paints catalog with detailed descriptions, specifications, segments and tags.
-- Using generated UUIDs for products, category matches, and base units.

INSERT INTO products (product_id, sku_code, product_name, category, unit, description, segment, specifications, tags, active)
VALUES
    -- Interior Wall Coatings
    ('b1000000-0000-0000-0000-000000000001', 'INT_SILK_GLAM_MATT', 'Silk Glamor Matt', 'INTERIOR', 'L', 
     'Luxury matt-finish interior emulsion made with 100% acrylic. Delivers rich, velvety depth with superior stain resistance.',
     'Premium', 
     '["100% acrylic emulsion formulation", "Green Pro Certified (eco-safe)", "Superior washability — stains wipe off easily", "Retains matt finish for years without dulling", "Coverage: ~100–120 sq.ft per litre per coat"]'::jsonb,
     '["Matt", "Washable", "Eco-certified", "Interior"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000002', 'INT_SILK_GLAMART', 'Silk GlamArt', 'INTERIOR', 'L', 
     'Luxury textured interior paint that creates artistic wall patterns with depth and character. Ideal for feature walls.',
     'Premium', 
     '["Texture paint with decorative design capability", "Available in Metallica, Stucco, and Designer Finishes", "Creates 3D-like visual depth on flat walls", "Suitable for living rooms and accent walls"]'::jsonb,
     '["Textured", "Decorative", "Feature Wall"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000003', 'INT_SILK_LUX_EMUL', 'Silk Luxury Emulsion', 'INTERIOR', 'L', 
     'Rich, smooth finish emulsion delivering high-sheen elegance. Part of the Berger Silk range for upscale interiors.',
     'Premium', 
     '["High-gloss sheen for a polished look", "Even colour coverage across surfaces", "Resists moisture, stains, and daily wear", "Best for living rooms and bedrooms"]'::jsonb,
     '["Gloss-sheen", "Premium", "Smooth"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000004', 'INT_EASY_CLEAN', 'Easy Clean', 'INTERIOR', 'L', 
     'Premium acrylic-based paint designed for high-moisture and high-traffic areas. Outstanding scrub and wash resistance.',
     'Standard', 
     '["Excellent scrub resistance for frequent cleaning", "Ideal for kitchens, hallways, children''s rooms", "Water-based, low odour formulation", "Guards against stains from grease, food, crayons"]'::jsonb,
     '["Washable", "Kitchen-safe", "High-traffic"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000005', 'INT_RANGOLI_CARE', 'Rangoli Total Care', 'INTERIOR', 'L', 
     'Mid-range acrylic emulsion offering quality finish at a practical price point. Good colour retention and adhesion.',
     'Standard', 
     '["Acrylic-based formulation for durability", "Suitable for guest rooms and low-use areas", "Good adhesion on plaster, putty surfaces", "Available in 2500+ shades"]'::jsonb,
     '["Mid-range", "Versatile", "Acrylic"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000006', 'INT_BISON_EMUL', 'Bison Acrylic Emulsion', 'INTERIOR', 'L', 
     'Economical interior emulsion with a clean finish. Good for budget-conscious projects that don''t compromise on quality.',
     'Economy', 
     '["Smooth, uniform finish on interior walls", "Water-resistant surface", "Suitable for rental properties and budget projects", "Available in soft sheen and matt variants"]'::jsonb,
     '["Economy", "Emulsion", "Smooth"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000007', 'INT_BISON_DIST', 'Bison Distemper', 'INTERIOR', 'Kg', 
     'Dry powder distemper for an affordable, chalk-like matte finish. Good for temporary applications and low-budget interiors.',
     'Economy', 
     '["Dry distemper — requires mixing with water", "Excellent hide, covers wall imperfections", "Breathable finish, suitable for older constructions", "Not washable — not suitable for kitchens/bathrooms"]'::jsonb,
     '["Distemper", "Budget", "Powder"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000008', 'INT_CEILING_WHITE', 'Ceiling White', 'INTERIOR', 'L', 
     'Specially formulated thick paint to cover ceilings in a single coat. Anti-sag formula prevents drips during overhead application.',
     'Standard', 
     '["Thick formulation — covers in one coat", "Anti-sag: stays in place when applied overhead", "Bright white finish reduces need for artificial light", "Water-based, low odour"]'::jsonb,
     '["Ceiling", "One-coat", "Anti-sag"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000009', 'INT_SILK_BREATHE', 'Silk Breathe Easy', 'INTERIOR', 'L', 
     'Wellness-focused interior emulsion that actively reduces indoor air pollutants and inhibits microbial growth on walls.',
     'Premium', 
     '["Reduces indoor VOCs and airborne pollutants", "Anti-microbial properties suppress mold/bacteria", "Smooth finish with wellness-grade certification", "Ideal for bedrooms, nurseries, hospitals"]'::jsonb,
     '["Wellness", "Anti-microbial", "Air-purifying"]'::jsonb, true),

    -- Exterior Wall Coatings
    ('b1000000-0000-0000-0000-000000000010', 'EXT_WEATH_ANTI_DUST', 'WeatherCoat Anti Dustt', 'EXTERIOR', 'L', 
     'Advanced exterior emulsion with a special anti-dust technology that repels fine dust from settling on the surface. Prevents algal and fungal growth.',
     'Standard', 
     '["Anti-dust technology — dust slides off surface", "Prevents algae and fungal growth on walls", "UV resistant — colour stays vibrant longer", "Warranty: 6 years", "Ideal for polluted urban environments"]'::jsonb,
     '["Anti-dust", "Anti-fungal", "UV resistant"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000011', 'EXT_WEATH_LONGLIFE', 'WeatherCoat Longlife', 'EXTERIOR', 'L', 
     'Premium long-duration exterior emulsion offering exceptional protection against the elements. One of Berger''s most durable exterior solutions.',
     'Premium', 
     '["Exceptional durability — 10+ year protection", "Superior UV resistance against fading", "Anti-algal and anti-fungal additives", "Elastomeric properties — bridges hairline cracks", "Self-cleaning in rain"]'::jsonb,
     '["Long-lasting", "Elastomeric", "Premium"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000012', 'EXT_WALMASTA', 'Walmasta', 'EXTERIOR', 'L', 
     '100% water-based exterior coating with anti-cracking and anti-flaking properties. Retains vibrant colour over time.',
     'Standard', 
     '["100% water-based — zero solvent content", "Anti-cracking formulation for stable walls", "Anti-flaking — paint stays adhered over years", "Vibrant colour retention under sun exposure"]'::jsonb,
     '["Water-based", "Anti-crack", "Exterior"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000013', 'EXT_TEXTURE_FIN', 'Exterior Texture Finishes', 'EXTERIOR', 'L', 
     'Heavy-bodied textured coatings that add 3D aesthetics to outer walls while hiding cracks and surface imperfections.',
     'Premium', 
     '["Hides surface cracks and rough masonry", "Available in sand, pebble, and smooth texture styles", "Highly durable — handles harsh weather", "Reduces heat absorption through thick film layer"]'::jsonb,
     '["Textured", "3D Effect", "Crack-hiding"]'::jsonb, true),

    -- Enamel Paints
    ('b1000000-0000-0000-0000-000000000014', 'ENM_LUX_HI_GLOSS', 'Luxol Hi-Gloss Enamel', 'ENAMEL', 'L', 
     'Berger''s flagship enamel with a mirror-like gloss finish. Widely used on doors, windows, railings, and metal furniture.',
     'Premium', 
     '["Highest-sheen gloss among Berger enamels", "Protects against rust, moisture, scratches", "Ideal for: doors, window frames, metal gates", "Available in white, mahogany brown, and custom tints", "Thinning: use turpentine/recommended thinner"]'::jsonb,
     '["Gloss", "Metal", "Wood", "Synthetic"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000015', 'ENM_LUX_SATIN', 'Luxol Satin Enamel', 'ENAMEL', 'L', 
     'Semi-gloss (satin) enamel finish that is less reflective than Hi-Gloss but equally durable. Popular for interior woodwork.',
     'Premium', 
     '["Soft satin sheen — elegant, not overpowering", "Excellent stain and dirt resistance", "Suitable for both indoor and outdoor metal", "Dries to a hard, uniform surface"]'::jsonb,
     '["Satin", "Elegant", "Durable"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000016', 'ENM_LUX_PU', 'Luxol PU Enamel', 'ENAMEL', 'L', 
     'Polyurethane-based enamel offering chemical resistance, UV stability, and exceptional gloss. Used on floors and high-use surfaces.',
     'Premium', 
     '["PU chemistry — creates very tough, hard film", "UV resistant — does not yellow or fade in sunlight", "Resistant to chemicals, oils, and cleaning agents", "Suitable for floors, industrial equipment, furniture", "High clarity and colour retention"]'::jsonb,
     '["PU", "UV resistant", "Chemical resistant"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000017', 'ENM_BUTTERFLY', 'Butterfly Enamel', 'ENAMEL', 'L', 
     'Economy synthetic enamel providing a glossy, protective finish at an accessible price point. Good for general-purpose metal and wood painting.',
     'Economy', 
     '["Synthetic oil-based enamel formulation", "Good gloss and coverage for the price", "Standard rust and stain protection", "Suitable for grills, gates, fences"]'::jsonb,
     '["Economy", "Gloss", "Synthetic"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000018', 'ENM_ACRY_WATER', 'Acrylic Enamel (Water-based)', 'ENAMEL', 'L', 
     'Water-based enamel that dries faster, has lower odour, and is easier to clean up than synthetic enamel. Best for interior applications.',
     'Standard', 
     '["Water-based — clean-up with water, no solvent", "Faster drying than synthetic enamel", "Low odour — suitable for occupied spaces", "Flexible — resists cracking from temperature changes"]'::jsonb,
     '["Water-based", "Fast-dry", "Low-odour"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000019', 'ENM_EPOXY', 'Epoxy Enamel', 'ENAMEL', 'L', 
     'Two-part enamel system (epoxy resin + hardener) providing maximum hardness, water resistance, and chemical durability for industrial uses.',
     'Premium', 
     '["Two-component system — mix before applying", "Highest heat and chemical resistance", "Waterproof and very hard film formation", "Used in workshops, factories, and heavy-duty floors"]'::jsonb,
     '["2K", "Industrial", "Epoxy", "Waterproof"]'::jsonb, true),

    -- Wood Finishes
    ('b1000000-0000-0000-0000-000000000020', 'WOD_IMP_TRENDZ', 'Imperia Trendz', 'WOOD', 'L', 
     'High-end 2K (two-component) acrylic PU finishing system for furniture and doors. Delivers exotic, luxury aesthetics with a pearl finish.',
     'Premium', 
     '["2K PU system — mix hardener + base before use", "Pearl and exotic finish options", "Reveals and enhances natural wood grain", "Excellent durability against scratches and stains", "Suitable for: premium furniture, cabinet doors"]'::jsonb,
     '["2K PU", "Pearl finish", "Luxury"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000021', 'WOD_IMP_GRANDE', 'Imperia Grande', 'WOOD', 'L', 
     'High-quality matt finish for both exterior and interior woodwork. UV stabilisers and plasticisers provide flexibility and outdoor durability.',
     'Premium', 
     '["UV stabilisers prevent yellowing in sunlight", "Plasticisers add flexibility — resists cracking", "Water repellent due to silicone additives", "Anti-fungal agents for outdoor use", "Suitable for outdoor furniture and decking"]'::jsonb,
     '["Matt", "Outdoor", "UV stable"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000022', 'WOD_IMP_GOLD', 'Imperia Gold', 'WOOD', 'L', 
     'Clear gloss coating that showcases natural wood grain with a shiny protective layer. The "glass slab" finish option gives ultra-smooth, deep clarity.',
     'Premium', 
     '["Transparent — lets natural wood grain shine through", "High-gloss, wet-look clarity", "Durable protection against weather and scratches", "Ideal for high-end furniture and panelling"]'::jsonb,
     '["Clear Gloss", "Grain-enhancing", "High-end"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000023', 'WOD_IMP_POLY', 'Imperia Polyester', 'WOOD', 'L', 
     'Ultra-thick, three-in-one glossy polyester finish that creates a glass-like surface with exceptional depth and clarity.',
     'Premium', 
     '["Three-in-one product: sealer + body + topcoat", "Glass-like finish with extreme depth and clarity", "Extremely hard and thick protective film", "Ideal for luxury kitchen cabinets, display furniture"]'::jsonb,
     '["Polyester", "Glass finish", "3-in-1"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000024', 'WOD_MELAMINE', 'Melamine 24 Carat', 'WOOD', 'L', 
     'Melamine polish delivering a mirror-like gloss finish with vibrant clarity. Low odour and ideal for indoor furniture.',
     'Standard', 
     '["Mirror-like gloss — luxurious sheen", "Vibrant colour and high clarity", "Low odour formulation — comfortable indoors", "Best for: indoor furniture, cabinets, tables", "Not recommended for outdoor/wet areas"]'::jsonb,
     '["Melamine", "Mirror gloss", "Indoor"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000025', 'WOD_RAINBOW', 'Rainbow PU', 'WOOD', 'L', 
     'Flexible polyurethane finish offering crystal-clear, vibrant hues for both interior and exterior woodwork. Resists cracking.',
     'Standard', 
     '["Flexible PU formulation — won''t crack with movement", "Vibrant, clear finish with rich colours", "Suitable for both indoor and outdoor applications", "Slightly more odour than melamine during application"]'::jsonb,
     '["PU", "Flexible", "Indoor+Outdoor"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000026', 'WOD_PROTEKTOR', 'Wood Protektor', 'WOOD', 'L', 
     'Multi-shade protective coating for both interior and exterior wood. Simple application makes it popular among DIY users.',
     'Standard', 
     '["Easy to use — suitable for DIY projects", "Multi-shade options available", "Protects against moisture, UV, and pests", "Works on hardwood and softwood both"]'::jsonb,
     '["DIY", "Protective", "Multi-shade"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000027', 'WOD_BLOCK_PRIMER', 'Wood Block Primer', 'WOOD', 'L', 
     'Specialised base coat that blocks tannins, resins, and stains from bleeding through the topcoat. Ensures even finish on raw wood.',
     'Standard', 
     '["Blocks tannins and resin bleed-through", "Strengthens paint adhesion to wood", "Resolves prolonged drying problems on oily woods", "Essential step before applying any topcoat on bare wood"]'::jsonb,
     '["Primer", "Stain-blocker", "Adhesion"]'::jsonb, true),

    -- Waterproofing Solutions
    ('b1000000-0000-0000-0000-000000000028', 'WPR_DAMPSTOP_ADV', 'Dampstop Advanced', 'WATERPROOF', 'L', 
     'Ready-to-use penetrative waterproofing system. Nano additives block pores in the wall substrate, forming a watertight barrier from within.',
     'Standard', 
     '["One-component — ready to use, no mixing", "Nano additives fill microscopic pores in substrate", "Dual action: penetrates AND forms a film on surface", "Prevents salt leaching (efflorescence) on walls", "Excellent adhesion to plaster, concrete, masonry", "Warranty: 3 years against dampness and efflorescence"]'::jsonb,
     '["Nano-tech", "Penetrative", "Ready-to-use"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000029', 'WPR_DAMPSTOP_DUO', 'HomeShield Dampstop Duo', 'WATERPROOF', 'L', 
     'Nano-technology waterproof primer that blocks moisture from both water-side and air-side, giving dual-direction protection.',
     'Standard', 
     '["Nano-technology based — deep penetration", "Works as waterproof primer under topcoats", "Ready to use — apply directly to damp/dry walls", "Prevents mold and mildew growth"]'::jsonb,
     '["Nano", "Primer", "Dual-action"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000030', 'WPR_ROOF_KOOL', 'HomeShield Roof Kool & Seal', 'WATERPROOF', 'L', 
     'Terrace waterproofing coating with heat-reflecting (cool roof) properties. Reduces indoor temperature while sealing the roof against water.',
     'Standard', 
     '["Heat-reflective pigments reduce roof temperature", "Lowers indoor ambient temperature by 3–5°C", "Watertight membrane for terrace protection", "Elastomeric — bridges small cracks in the slab", "Suitable for concrete and asbestos roofs"]'::jsonb,
     '["Cool roof", "Heat-reflective", "Terrace"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000031', 'WPR_PU_ROOFKOAT', 'HomeShield PU Roofkoat', 'WATERPROOF', 'L', 
     'Single-component polyurethane liquid membrane. Extremely elastic and UV-resistant — forms a seamless waterproof skin over the roof.',
     'Standard', 
     '["One-component PU — easy application", "Highly elastic membrane — stretches with building movement", "UV resistant — does not degrade under sunlight", "Seamless film — no joints or weak points", "Suitable for: flat roofs, terraces, balconies"]'::jsonb,
     '["PU membrane", "Elastic", "Seamless"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000032', 'WPR_PU_ELASTOSEAL', 'HomeShield PU Elastoseal Non-UV 1K', 'WATERPROOF', 'L', 
     'Highly flexible, single-component polyurethane sealant for expansion joints and cracks. Not for UV-exposed areas — use under a topcoat.',
     'Standard', 
     '["Fills and seals expansion joints and cracks", "Extremely flexible — accommodates building movement", "Not UV-stable — must be covered with topcoat", "Ideal for: basement walls, internal slabs, joints"]'::jsonb,
     '["Sealant", "Joints", "1K PU"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000033', 'WPR_REPAIRO', 'HomeShield Repairo', 'WATERPROOF', 'Kg', 
     'Crack and surface repair product for walls and concrete. Fills damaged areas before waterproofing treatment is applied.',
     'Standard', 
     '["Fills cracks, voids, and surface holes", "Strong bond with concrete and plaster substrates", "Pre-waterproofing surface preparation product", "Can be painted over after curing"]'::jsonb,
     '["Crack repair", "Surface prep", "Mortar"]'::jsonb, true),

    -- Primers & Undercoats
    ('b1000000-0000-0000-0000-000000000034', 'PRM_ACRY_WALL', 'Acrylic Wall Primer', 'PRIMER', 'L', 
     'Water-based primer for interior plaster walls. Seals porous surfaces and provides a smooth, even base for emulsion topcoats.',
     'Standard', 
     '["Water-based — low odour, easy clean-up", "Seals porosity of new plaster and putty", "Improves topcoat adhesion significantly", "Reduces paint consumption on first coat", "Quick-dry: typically 2–4 hours"]'::jsonb,
     '["Water-based", "Interior", "Sealer"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000035', 'PRM_EXT_CEMENT', 'Exterior Cement Primer', 'PRIMER', 'L', 
     'Alkali-resistant primer formulated for outdoor cement and plaster surfaces. Neutralises alkali in new cement before painting.',
     'Standard', 
     '["Alkali-resistant chemistry — protects topcoat from cement burn", "Prevents saponification of topcoat on new walls", "Improves weathering resistance of topcoat", "Suitable for: exterior RCC walls, plaster, masonry"]'::jsonb,
     '["Alkali-resistant", "Exterior", "Cement"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000036', 'PRM_METAL_ANTICORR', 'Anti-Corrosive Metal Primer', 'PRIMER', 'L', 
     'Rust-inhibiting primer for iron, steel, and other metal surfaces. Creates a barrier that stops oxygen and moisture from reaching the metal.',
     'Standard', 
     '["Red oxide formulation — inhibits rust formation", "Bonds tightly to bare metal and treated surfaces", "Suitable under synthetic or PU enamel topcoats", "Use on: gates, grills, railings, structural steel"]'::jsonb,
     '["Red oxide", "Rust-inhibiting", "Metal"]'::jsonb, true),

    ('b1000000-0000-0000-0000-000000000037', 'PRM_WALL_PUTTY', 'Wall Putty', 'PRIMER', 'Kg', 
     'White cement-based putty that fills surface irregularities, minor cracks, and pinholes before painting. Creates the smoothest possible base.',
     'Standard', 
     '["White cement base — bright, smooth finish", "Fills pinholes, micro-cracks, surface voids", "Applied 1–2 coats before primer and paint", "Sanded smooth after drying for best results"]'::jsonb,
     '["Putty", "Filler", "Basecoat"]'::jsonb, true)

ON CONFLICT (sku_code) DO UPDATE SET
    product_name = EXCLUDED.product_name,
    category = EXCLUDED.category,
    unit = EXCLUDED.unit,
    description = EXCLUDED.description,
    segment = EXCLUDED.segment,
    specifications = EXCLUDED.specifications,
    tags = EXCLUDED.tags,
    active = EXCLUDED.active;

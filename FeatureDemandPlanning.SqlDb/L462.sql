-- Update the brochure model codes for L462 as they are currently missing (or wrong in current versions)
-- Note that these codes may not necessarily be correct, it just allows mapping to be performed

-- 3.0 Diesel TD6 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'GBBV'
WHERE
Id IN (645, 646, 647, 648, 649)

-- 5.0 V8 Petrol S/C 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'GCBV'
WHERE
Id IN (796, 797, 798, 799, 800)

-- 3.0 Petrol V6 S/C 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'GDBV'
WHERE
Id IN (650, 651, 652, 653, 654)

-- 2.0 Diesel SD4 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'GLBV'
WHERE
Id IN (655, 656, 657, 658)

-- 2.0 Diesel TD4 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'GZBV'
WHERE
Id IN (659, 660, 661, 662)


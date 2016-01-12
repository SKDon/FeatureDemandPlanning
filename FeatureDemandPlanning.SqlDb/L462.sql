-- Update the brochure model codes for L462 as they are currently missing

-- V8 Petrol 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'GDVH' 
WHERE Id IN (650, 651, 652, 653, 654)
AND
BMC IS NULL

-- V6 Petrol 4x4 SWB
--UPDATE OXO_Programme_Model SET BMC = 'HQCH' 
--WHERE Id IN (645, 646, 647, 648, 649)
--AND
--BMC IS NULL

-- 2.0 Si4 Petrol 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'HQVH' 
WHERE Id IN (646, 647, 648, 649)
AND
BMC IS NULL

-- SDV8 Diesel 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'HSCH' 
WHERE Id IN (1475, 1476, 1477)
AND
BMC IS NULL

-- SDV6 Diesel 4x4 SWB
UPDATE OXO_Programme_Model SET BMC = 'HSVH' 
WHERE Id IN (1478, 1479, 1480, 1481, 1482)
AND
BMC IS NULL


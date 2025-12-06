-- we already have PRD loaded until 2025-10-17 and ACC loaded until 2025-10-01.
-- therefore remove all files before 2025-10-01

LIST   @stg.SSV_SOURCES_NSRA/Archive/Addresses;


-- Remove all of 2024 files
LIST   @stg.SSV_SOURCES_NSRA/Archive PATTERN='.*_2024.*';
REMOVE @stg.SSV_SOURCES_NSRA/Archive PATTERN='.*_2024.*';
LIST   @stg.SSV_SOURCES_NSRA/Archive/Addresses;

-- Remove files from 2025-01 to -09
LIST   @stg.SSV_SOURCES_NSRA/Archive/Addresses PATTERN='.*_20250.*';
REMOVE @stg.SSV_SOURCES_NSRA/Archive PATTERN='.*_20250.*';
LIST   @stg.SSV_SOURCES_NSRA/Archive/Addresses;
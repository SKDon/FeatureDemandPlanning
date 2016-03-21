-- Flush data script for testing

-- Changesets

DELETE FROM Fdp_ChangesetDataItem
DELETE FROM Fdp_Changeset

-- Take rate data

DELETE FROM Fdp_TakeRateDataItemAudit
DELETE FROM Fdp_PowertrainDataItemAudit
DELETE FROM Fdp_TakeRateFeatureMixAudit
DELETE FROM Fdp_VolumeDataItem
DELETE FROM Fdp_TakeRateFeatureMix
DELETE FROM Fdp_TakeRateSummaryAudit
DELETE FROM Fdp_TakeRateSummary
DELETE FROM Fdp_PowertrainDataItem
DELETE FROM Fdp_VolumeHeader

-- Imports

DELETE FROM Fdp_ImportError
DELETE FROM Fdp_ImportData
DELETE FROM Fdp_Import
DELETE FROM Fdp_ImportQueueError
DELETE FROM Fdp_ImportQueue

-- Mappings

DELETE FROM Fdp_DerivativeMapping
DELETE FROM Fdp_TrimMapping
DELETE FROM Fdp_FeatureMapping
DELETE FROM Fdp_Derivative
DELETE FROM Fdp_Trim
DELETE FROM Fdp_Feature
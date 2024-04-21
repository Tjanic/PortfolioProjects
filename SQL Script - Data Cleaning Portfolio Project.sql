/*
Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..HousingData

--	Standardize Date format
SELECT Saledate, CONVERT(date,saledate)
FROM PortfolioProject..HousingData

UPDATE HousingData 
SET Saledate = CONVERT(date,saledate)

ALTER TABLE HousingData
ADD SaleDateConverted Date;

UPDATE HousingData
SET SaleDateConverted = CONVERT(date,saledate)

-- Populate Property Address Data

SELECT *
FROM PortfolioProject..HousingData
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress,b.PropertyAddress)
FROM PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
ON a.ParcelID = b.ParcelID 
AND a.[uniqueID] <> b.[uniqueID]
WHERE a.propertyaddress is null

UPDATE a
SET propertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
FROM PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
ON a.ParcelID = b.ParcelID 
AND a.[uniqueID] <> b.[uniqueID]
WHERE a.propertyaddress is null

-- Breaking out Address Into individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..HousingData
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS ADDRESS
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress nvarchar(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingData
ADD PropertySplitCity nvarchar(255);

UPDATE HousingData
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




Select OwnerAddress
From housingdata

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
From Portfolioproject..HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress nvarchar(255);

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)


ALTER TABLE HousingData
ADD OwnerSplitCity nvarchar(255);

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE HousingData
ADD OwnerSplitState nvarchar(255);

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


-- Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(Soldasvacant)
From Portfolioproject..HousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolioproject..HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM Portfolioproject..HousingData
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE Row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

Select *
From Portfolioproject..HousingData

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, 


ALTER TABLE HousingData
DROP COLUMN SaleDate
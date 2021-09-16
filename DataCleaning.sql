/*

Data Cleaning in SQL

*/

SELECT *
FROM PortfolioProject.dbo.Nashville

----------------------------------------------------------------------------

-- Standardized Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM Nashville

UPDATE Nashville
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Nashville
ADD SaleDateConverted DATE;

UPDATE Nashville
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM Nashville


-------------------------------------------------------


--- Populate Property Address Data

SELECT *
FROM Nashville
----WHERE PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


------------------------------------------------------------------------

--- Breaking Out Address into Individual Columns (Address, City, Address)

SELECT PropertyAddress
FROM PortfolioProject..Nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ADD ProppertyAddressSplitAddress NvarChar(255);

UPDATE PortfolioProject..Nashville
SET ProppertyAddressSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject..Nashville
ADD ProppertyAddressSplitCity NvarChar(255);

UPDATE PortfolioProject..Nashville
SET ProppertyAddressSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..Nashville



SELECT OwnerAddress
FROM PortfolioProject..Nashville

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitAddress NvarChar(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitCity NvarChar(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitState NvarChar(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..Nashville


-------------------------------------------------------------------------------------------------

----- Change Y and N to Yes and No in 'SoldAsVacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject..Nashville

UPDATE PortfolioProject..Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject..Nashville


--------------------------------------------------------------------------------------------------------

----- REMOVE DUPLICATES

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..Nashville
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




Select *
From PortfolioProject..Nashville




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject..Nashville


ALTER TABLE PortfolioProject..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
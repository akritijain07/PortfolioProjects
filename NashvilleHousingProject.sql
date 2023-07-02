SELECT * FROM NashvilleHousing


-- STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
-- this method is not working

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing

---------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA

-- selecting rows where data is null
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- on analysing data it is found that 2 matching ParcelIDs have matching PropertyAddress too
-- selecting matching ParcelIDs where one of them has null PropertyAddress
SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE ParcelID IN (SELECT ParcelID 
					FROM NashvilleHousing
					WHERE PropertyAddress IS NULL)

-- selecting using joins				
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- updating sheet to set null PropertyAddress to the data of the matching ParcelID
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------
-- SPLITTING PropertyAddress INTO ADDRESS, CITY

-- selecting different parts of the PropertyAddress using substring
SELECT PropertyAddress, 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

-- adding new columns to table to accomodate the split parts
ALTER TABLE NashvilleHousing
ADD PropertyAddressConverted nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity nvarchar(255);

-- putting data into the new columns
UPDATE NashvilleHousing
SET PropertyAddressConverted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------
-- SPLITTING OwnerAddress INTO ADDRESS, CITY, STATE

-- selecting different parts of OwnerAddress using parsename
SELECT OwnerAddress,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM NashvilleHousing

-- adding new columns to table to accomodate the split parts
ALTER TABLE NashvilleHousing
ADD OwnerAddressConverted nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerAddressCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerAddressState nvarchar(255);

-- putting data into the new columns
UPDATE NashvilleHousing
SET OwnerAddressConverted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------
-- CHANGE Y AND N TO YES AND NO IN SoldAsVacant FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS count
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY count

-- replacing Y and N with yes and no
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

-- updating in table
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

-------------------------------------------------------------------------
-- REMOVING DUPLICATES

WITH rownumCTE AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
		ORDER BY ParcelID) AS row_num
FROM NashvilleHousing
)
DELETE
FROM rownumCTE
WHERE row_num > 1








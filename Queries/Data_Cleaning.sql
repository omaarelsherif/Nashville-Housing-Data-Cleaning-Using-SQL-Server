/******************** Nashville Housing Data Cleaning ********************/

-- Show the data
SELECT * FROM NashvilleHousing

-----------------------------------------------------------------------------

/***** Standardize Date Format *****/

-- Show SaleDate column and its converted date version
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

-- Update data type of SaleDate column to date
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

-----------------------------------------------------------------------------

/***** Populate Property Address data *****/

-- Show PropertyAddress column and check if there are NULL values
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- Show all date orderd by ParceID
SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

-- Self join to check ParceID
SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

-- Update PropertyAddress if it NULL
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------

/***** Breaking out Address into Individual Columns (Address, City, State) *****/

-- Show OwnerAddress column
SELECT OwnerAddress
FROM NashvilleHousing

-- Split OwnerAddress into 3 parts as Address, City and State
Select
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
From NashvilleHousing

-- Add new columns for Address, City and State
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255)

-- Update columns values
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-----------------------------------------------------------------------------

/***** Change Y and N to Yes and No in "Sold as Vacant" field *****/

-- Show SoldAsVacant column and it's count
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

-- Use case statement to replace Y with Yes and N with No
Select SoldAsVacant, 
CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
From NashvilleHousing

-- Update SoldAsVacant column
Update NashvilleHousing
SET SoldAsVacant = CASE 
						When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END

-----------------------------------------------------------------------------

/***** Remove Duplicates *****/

-- Write a CTE
WITH RowNumCTE AS
(
	Select 
		*,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID
						) row_num

	From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From NashvilleHousing

-----------------------------------------------------------------------------

/***** Delete Unused Columns *****/

-- Show all data
Select *
From NashvilleHousing

-- Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------------
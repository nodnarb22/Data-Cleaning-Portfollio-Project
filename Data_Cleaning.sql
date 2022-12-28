/*
Cleaning Data in SQL Queries
*/

Select *
From dbo.NashvilleHousing

-----------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
Add SaleDateConverted Date;

Update dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------

-- Populate Property Address data

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-----------------------------------

-- Breaking up Address into individual columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
Add PropertySpliltAddress Nvarchar(255);

Update dbo.NashvilleHousing
SET PropertySpliltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing



Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From dbo.NashvilleHousing



ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From dbo.NashvilleHousing

-----------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant"  field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select DISTINCT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From dbo.NashvilleHousing

Update dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-----------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY
		UniqueID) row_num
	
From dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

-----------------------------------

-- Delete Unused Columns

Select *
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
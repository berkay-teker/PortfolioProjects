/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

--If the above code is not working try this one

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Drop Column SaleDate

--After above code I change column order with Design Tab of Table

--------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null
 

--------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing

-- -1 using for get rid of comma
-- +1 using for get rid of comma also if we didnt use it address(city) starts with comma

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress

--After above code I change column order with Design Tab of Table 

Select OwnerAddress
From NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',','.'), 3)
,Parsename(Replace(OwnerAddress, ',','.'), 2)
,Parsename(Replace(OwnerAddress, ',','.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'), 1)

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress

--After above code I change column order with Design Tab of Table 

--Change Y and N to Yes and No in SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


--------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS(
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

From NashvilleHousing
--Order By ParcelID
)
--Delete
--From RowNumCTE
--Where row_num > 1
--Order By PropertySplitAddress

-- Delete command is above

Select *
From RowNumCTE
Where row_num > 1
Order By PropertySplitAddress

--------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column TaxDistrict
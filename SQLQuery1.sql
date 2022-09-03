/* 
Cleaning Data in SQL Queries

*/

Select *
From dbo.NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Update NashvilleHousing
Set SaleDate = CONVERT(DATE, SaleDate) 
 
 Alter Table NashvilleHousing
 Alter Column SaleDate date

Select SaleDate
From dbo.NashvilleHousing

------------------------------------------------------------------------------------
--Populate Property Address data

Select PropertyAddress, ParcelID
From dbo.NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID desc

Select pro.ParcelID, pro.PropertyAddress, par.ParcelID, par.PropertyAddress, ISNULL(pro.PropertyAddress,par.PropertyAddress)
From dbo.NashvilleHousing pro
Join dbo.NashvilleHousing par
On pro.ParcelID = par.ParcelID
and pro.[UniqueID ] <> par.[UniqueID ]
Where par.PropertyAddress is Null


Update pro
Set PropertyAddress = ISNULL(pro.PropertyAddress,par.PropertyAddress)
From dbo.NashvilleHousing pro
Join dbo.NashvilleHousing par
On pro.ParcelID = par.ParcelID
and pro.[UniqueID ] <> par.[UniqueID ]

--Checking if we still have Nulls

Select PropertyAddress, [UniqueID ], ParcelID
From dbo.NashvilleHousing
Where PropertyAddress is Null


-----------------------------------------------------------
--Breaking out Address into individual Columns (Address, City, State)


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As City
From NashvilleHousing


 Alter Table NashvilleHousing
 Add Address varchar(255)

Update NashvilleHousing
Set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

 Alter Table NashvilleHousing
 Add City varchar(255)

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
   
   
 Alter Table NashvilleHousing
 Add State varchar(255)
 
 
Update NashvilleHousing
Set State = Right (OwnerAddress, CHARINDEX('.', OwnerAddress) +3)
 
  
Select OwnerAddress, Right(OwnerAddress, CHARINDEX('.', OwnerAddress) +3) As State
From dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

--Change Y and N to Yees and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldASVacant
,Case When SoldAsVacant = 'Y' Then 'Yes' 
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes' 
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End 
------------------------------------------------------------------------------------------
--Remove Duplicates
With RowNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition By
				ParcelID,
				UniqueID,
				PropertyAddress,
				SalePrice,
				LegalReference
				Order By 
					UniqueID
					) row_num

From dbo.NashvilleHousing
--Order By ParcelID 
)

Select*
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


------------------------------------------------------------------------------------
--Delete Unused Columns
Select *
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict








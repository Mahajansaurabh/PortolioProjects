/*

Cleaning Data in SQL Queries

*/

select * from Portfolio.dbo.Nashville

-- Standardize Date Format

select SaleDateConverted , CONVERT(Date,SaleDate) from Portfolio.dbo.Nashville

Update Nashville SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville Add SaleDateConverted Date;

Update Nashville SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Popular Property Address data

Select PropertyAddress from Portfolio.dbo.Nashville 
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio.dbo.Nashville a
Join Portfolio.dbo.Nashville b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is Null

 Update a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from Portfolio.dbo.Nashville a
 Join Portfolio.dbo.Nashville b
   ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is Null

--Breaking out Address into Individual Columns (Address, City,State)

Select PropertyAddress from Portfolio.dbo.Nashville 
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1, CharIndex(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Portfolio.dbo.Nashville 


ALTER TABLE Nashville Add PropertySplitAddress Nvarchar(255);

Update Nashville SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CharIndex(',',PropertyAddress) -1)

ALTER TABLE Nashville Add PropertySplitCity Nvarchar(255);

Update Nashville SET PropertySplitCity = SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress) +1, LEN(PropertyAddress))




Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Portfolio.dbo.Nashville 


ALTER TABLE Nashville 
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio.dbo.Nashville 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Portfolio.dbo.Nashville
Add OwnerSplitCity Nvarchar(255);

Update Portfolio.dbo.Nashville 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE Portfolio.dbo.Nashville
Add OwnerSplitState Nvarchar(255);

Update Portfolio.dbo.Nashville 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 




-- Change Y and N in 'Sold as Vacant' field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio.dbo.Nashville 
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
From Portfolio.dbo.Nashville

Update Portfolio.dbo.Nashville
SET SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END


--Remove Duplicates

With RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			      UniqueID
				  ) row_num

From Portfolio.dbo.Nashville
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress







--Delete Unused Columns

Select *
From Portfolio.dbo.Nashville

Alter Table Portfolio.dbo.Nashville
Drop Column OwnerAddress, TaxDistrict , PropertyAddress

Alter Table Portfolio.dbo.Nashville
Drop Column SaleDate
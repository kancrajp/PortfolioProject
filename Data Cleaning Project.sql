
/* Cleaning data in Sql query
                          */

Select *
from PortfolioProject..[Nashville Housing]

-- Standerized Data format

Select SalesDate, CONVERT(Date, SaleDate) 
from PortfolioProject..[Nashville Housing]

update [Nashville Housing]
set SaleDate = CONVERT(Date, SaleDate)

Alter table [Nashville Housing]
add SalesDate Date

update [Nashville Housing]
set SalesDate = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------------------------------


--- Populate Property Address Data


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
-- where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from PortfolioProject..[Nashville Housing]
-- where PropertyAddress is null
-- order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

from PortfolioProject..[Nashville Housing]


Alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255)

update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 



Alter table [Nashville Housing]
add PropertySplitCity nvarchar(255)

update [Nashville Housing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select *
from PortfolioProject..[Nashville Housing]


------------------------------------------------------------------------------------------------------------------------

select OwnerAddress
from PortfolioProject..[Nashville Housing]

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..[Nashville Housing]



Alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255)

update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255)

update [Nashville Housing]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter table [Nashville Housing]
add OwnerSplitstate nvarchar(255)

update [Nashville Housing]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject..[Nashville Housing]


-------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y & N to Yes and NO in 'Sold as Vacant' Field

select SoldAsVacant
from PortfolioProject..[Nashville Housing]

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..[Nashville Housing]
Group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..[Nashville Housing]


update [Nashville Housing]
set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
select *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
				   UniqueID
				   ) row_num
from PortfolioProject.dbo.[Nashville Housing]
-- order by ParcelID
)

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

--Delete 
--from RowNumCTE
--where row_num > 1
---- order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..[Nashville Housing]

ALTER table PortfolioProject..[Nashville Housing]
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER table PortfolioProject..[Nashville Housing]
DROP COLUMN SaleDate
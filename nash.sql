--standardize date format

ALTER TABLE Nash1
ADD SaleDate2 Date;

UPDATE Nash1
SET SaleDate2 = CONVERT(Date, SaleDate)



--Populate property address data 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Nash1 a
JOIN Nash1 b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Nash1 a
JOIN Nash1 b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--breaking out address into individual columns (address, city, state)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) as city, 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM NASHVILE..Nash1


ALTER TABLE NASHVILE..Nash1
ADD Address nvarchar(255)

UPDATE NASHVILE..Nash1
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1)
FROM NASHVILE..Nash1

ALTER TABLE NASHVILE..Nash1
ADD City nvarchar(255)

UPDATE NASHVILE..Nash1
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) 
FROM NASHVILE..Nash1

ALTER TABLE NASHVILE..Nash1
ADD State nvarchar(255)

UPDATE NASHVILE..Nash1
SET State = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM NASHVILE..Nash1 


--changing 'y' to yes and 'n' to no in sold as vacant

SELECT SoldAsVacant, CASE when SoldAsVacant = 'y' then 'Yes'
			when SoldAsVacant = 'n' then 'No'
			else SoldAsVacant
			END
FROM NASHVILE..Nash1

UPDATE NASHVILE..Nash1
SET SoldAsVacant = CASE when SoldAsVacant = 'y' then 'Yes'
			when SoldAsVacant = 'n' then 'No'
			else SoldAsVacant
			END
FROM NASHVILE..Nash1


--removing duplicates
WITH RowCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
ORDER BY UniqueID) row_num
FROM NASHVILE..Nash1
)
delete
FROM ROWCTE
WHERE row_num > 1


--deleting columns 

ALTER TABLE NASHVILE..Nash1
DROP COLUMN propertyAddress, OwnerAddress, SaleDate, TaxDistrict#

SELECT *
FROM NASHVILE..Nash1
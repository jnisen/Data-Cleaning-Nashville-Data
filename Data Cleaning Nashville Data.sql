-- DATA CLEANING

SELECT *
FROM Nashville_housing_data_2013_2016

-- CHECK DATA TYPE

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE '%NASHVILLE%'

-- STANDARIZE DATE FORMAT

UPDATE Nashville_housing_data_2013_2016
SET SaleDate = CONVERT(DATE, SaleDate)

-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM Nashville_housing_data_2013_2016
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- FIND THOSE WHO HAS THE SAME PARCELID BUT NOT INCLUDE IT TWICE, SO MAKE DIFFERENT UNIQUE ID
-- WE CAN SEE FOR EXAMPLE '092 06 0 273.00' THAT HAS ANOTHER UNIQUEID WITH PROPERTY ADDRESS.

SELECT *
FROM Nashville_housing_data_2013_2016 a
JOIN Nashville_housing_data_2013_2016 b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- FOR THOSE THAT HAS NULL IN TABLE a AFTER THE JOIN, POPULATE WITH TABLE b THAT HAS THE PROPERTY ADDRESS

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_housing_data_2013_2016 a
JOIN Nashville_housing_data_2013_2016 b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS

SELECT PropertyAddress
FROM Nashville_housing_data_2013_2016

SELECT 
	TRIM(REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress),',','.'),1))) as PropertySplitAddress,
	TRIM(REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress),',','.'),2))) as PropertySplitCity
FROM Nashville_housing_data_2013_2016
	
ALTER TABLE Nashville_housing_data_2013_2016
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_housing_data_2013_2016
SET PropertySplitAddress = TRIM(REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress),',','.'),1)))

ALTER TABLE Nashville_housing_data_2013_2016
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_housing_data_2013_2016
SET PropertySplitCity = TRIM(REVERSE(PARSENAME(REPLACE(REVERSE(PropertyAddress),',','.'),2)))


-- CHECK IF WE HAVE TWO NEW COLUMNS

SELECT *
FROM Nashville_housing_data_2013_2016

-- SPLIT INTO THREE COLUMNS - COLUMN OWNERADDRESS

Select OwnerAddress
From Nashville_housing_data_2013_2016


Select
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)),
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)),
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1))
From Nashville_housing_data_2013_2016


ALTER TABLE Nashville_housing_data_2013_2016
Add OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_housing_data_2013_2016
SET OwnerSplitAddress = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3))


ALTER TABLE Nashville_housing_data_2013_2016
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_housing_data_2013_2016
SET OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2))


ALTER TABLE Nashville_housing_data_2013_2016
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_housing_data_2013_2016
SET OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1))

-- CHECK IF WE HAVE THREE NEW COLUMNS

Select *
From Nashville_housing_data_2013_2016


-- CHANGE 1 AND 0 TO YES AND NO IN "Sold as Vacant" FIELD

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_housing_data_2013_2016
Group by SoldAsVacant
order by 2

Select 
	SoldAsVacant, 
	IIF(SoldAsVacant = 1, 'Yes','No')
From Nashville_housing_data_2013_2016

ALTER TABLE Nashville_housing_data_2013_2016
ADD SoldAsVacantString NVARCHAR(255);

UPDATE Nashville_housing_data_2013_2016
SET SoldAsVacantString = IIF(SoldAsVacant = 1, 'Yes','No')

-- CHECK IF WE HAVE THREE NEW COLUMNS

Select *
From Nashville_housing_data_2013_2016


-- DETECT DUPLICATES

WITH RowNumCTE AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER(PARTITION BY PARCELID, PROPERTYADDRESS, SalePrice, SaleDate, LegalReference ORDER BY UNIQUEID) row_numb
	FROM Nashville_housing_data_2013_2016
)

SELECT * 
FROM RowNumCTE
WHERE row_numb > 1
ORDER BY PROPERTYADDRESS

-- REMOVE DUPLICATES

DELETE
FROM RowNumCTE
WHERE row_numb > 1


-- DELETE 104 ROWS DUPLICATES. 

Select *
From Nashville_housing_data_2013_2016


-- DROP UNNECESARY COLUMNS 

ALTER TABLE Nashville_housing_data_2013_2016
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant
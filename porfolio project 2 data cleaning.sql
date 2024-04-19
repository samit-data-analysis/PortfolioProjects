--Cleaning date in SQL queries

  Select*
  from [ Housing_Data ]

  --Standardize date format

select saledateconverted, convert(date,saledate)
from [ Housing_Data ] 

Update [ Housing_Data ]
set SaleDate = convert(date,saledate)

Alter table [ Housing_Data ]
add saledateconverted date;

Update [ Housing_Data ]
set saledateconverted = convert(date,saledate)

--Populate Property address data

select*
from [ Housing_Data ] 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from [ Housing_Data ] a
join [ Housing_Data ] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from [ Housing_Data ] a
join [ Housing_Data ] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Breaking out address into individual columns (address,city,state)

Select PropertyAddress
from [ Housing_Data ]

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',Propertyaddress)-1) as address
, SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyaddress)) as address
from [ Housing_Data ]

select PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from [ Housing_Data ]

Alter Table [ Housing_Data ]
add ownersplitaddress Nvarchar(255); 

Update [ Housing_Data ]
set ownersplitaddress = PARSENAME(Replace(owneraddress,',', '.'), 3)

Alter Table [ Housing_Data ]
add ownersplitcity Nvarchar(255); 

Update [ Housing_Data ]
set ownersplitcity = PARSENAME(Replace(owneraddress,',', '.'), 2)

Alter Table [ Housing_Data ]
add ownersplitstate Nvarchar(255);

Update [ Housing_Data ]
set ownersplitstate = PARSENAME(Replace(owneraddress,',', '.'), 1)

select*
from [ Housing_Data ]

-- Change Y and N and no in "Sold as Vacant" field 

select Distinct(SoldAsVacant),count(SoldAsVacant)
from [ Housing_Data ]
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
	   from [ Housing_Data ]



--Remove duplicates

With RownumCTE as(
select *,
     Row_number() over(
     Partition by ParcelId,
                  PropertyAddress,
			      SalePrice,
	 	          SaleDate,
				  LegalReference
                  Order by 
			        Uniqueid
			       ) row_num
 from [ Housing_Data ]
-- order by ParcelID
)
Select*
From Rownumcte
where row_num >1
order by propertyaddress 

Delete
From RownumCTE
where row_num >1
--order by propertyaddress


--Delete unused columns

select*
from [ Housing_Data ]

Alter table [ Housing_Data ]
drop column owneraddress, taxdistrict, propertyaddress

Alter table [ Housing_Data ]
drop column saledate
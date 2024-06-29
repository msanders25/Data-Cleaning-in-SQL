# Data Cleaning Project


## Project Overview
The purpose of this project was to demonstrate my process for cleaning a dataset and getting it ready for data analysis using SQL. The queries shown accomplish tasks such as restructuring data, modifying data types, splitting data into separate columns, converting timestamp data from one timezone to another, updating missing values, and so on. 

Review the SQL script *[HERE](https://github.com/msanders25/Data-Cleaning-in-SQL/blob/main/gym%20data%20cleaning.sql)*

The CSV dataset that I found to clean contains historical attendance numbers of open gym sessions at community centers in Cary, North Carolina. I chose this dataset to clean after viewing its original form and seeing all the data crammed into two columns which presented a good opportunity to showcase cleaning techniques. 

The original data can be found at this link: 
 - *[data.townofcary.org](https://data.townofcary.org/explore/dataset/open-gym/information/?disjunctive.facility_title&disjunctive.pass_type&disjunctive.community_center&disjunctive.open_gym&disjunctive.group)*

The raw data and resulting clean data have also been uploaded to this repository:
 - *[raw data](https://github.com/msanders25/Data-Cleaning-in-SQL/blob/main/nc_gym_data.csv)*
 - *[clean data](https://github.com/msanders25/Data-Cleaning-in-SQL/blob/main/clean%20gym%20data.csv)*

## Project Challenges and Solutions
There were several challenges that arose during this project but the challenges listed below were some of the most difficult. They required additional research to determine the best solution for producing the desired output.

### Challenge 1 - Combining and Separating the Original Data
The raw data downloaded from the Cary town website was initially formatted into a single column with data fields separated by semi-colons. Some rows contained data that seemed misplaced, originally intended for the first column but the second half of the data fields from column1 were placed in a second adjecent column.

### Solution 1
I used the substring_index function with a semi-colon delimiter (see step 3a in the SQL script) to isolate data fields into separate columns for column1. However, aligning data from column2 with column1 proved complex. To simplify, I concatenated non-repetitive text from column2 with combined data fields in column1 (see step 2 in SQL script), resulting in improved data alignment and subsequent separation.


### Challenge 2 - Populating Missing Values
The dataset contains several columns with information on total attendance for each gym session. The demographics of this info includes male, females, residents, and non-residents. Several rows had missing values where the reported attendance did not add up to the total column.

### Solution 2
I used subqueries and case statements (step 4a in the SQL script) to identify discrepancies where the total number of males and females didn't match the overall total. From there I was able to populate the missing values by subtracting the known attendance of one demographic from the total. See step 4d. The rest of the blank values were filled in with 0 where there was 0 attendance. Any other blank value that couldn't be derived or did not equal the reported total was deemed inaccurate and removed.


### Challenge 3 - Converting UTC to EDT
The start and end times in the original data were in UTC format where North Carolina is in EDT.

### Solution 3
This step required some research to determine the best syntax for converting the timezone to EDT. I stripped part of the timestamp data first and then modified the data type to datetime. From there I used the covert_tz function to change the timezones to reflect North Carolina time.













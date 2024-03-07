#SQL queries for the process phase
#Phase 3: Process
-- cleaning and filtering the data 
-- Remove columns from each table that are irrelevant
use bellabeat_data;
select * from dailyactivity_merged; /*this is the table name */
alter table dailyactivity_merged
drop column LoggedActivitiesDistance, 
drop column VeryActiveDistance, 
drop column ModeratelyActiveDistance, 
drop column LightActiveDistance, 
drop column SedentaryActiveDistance;
/*check the datatype and names of all columns in each table */
#Table 1 - dailyactivity_merged 
#I encountered error code 1175, so I added the safe updates statement
SET SQL_SAFE_UPDATES = 0;
describe dailyactivity_merged;
/*ActivityDate column was 'text' datatype. So changed it to 'date' and renamed it to 'date' */
update dailyactivity_merged
set ActivityDate = str_to_date(ActivityDate, '%m/%d/%Y');
alter table dailyactivity_merged
change column ActivityDate date date;

#Table 2 - sleepday_merged 
SET SQL_SAFE_UPDATES = 0;
describe sleepday_merged;
/* SleepDay column was 'text' datatype, so changed it to 'datetime' and renamed it to 'date_time' */
update sleepday_merged
set SleepDay = str_to_date(SleepDay, '%m/%d/%Y %h:%i:%s %p');
alter table sleepday_merged
change column SleepDay date_time datetime;

#Table 3 - hourlycalories_merged 
describe hourlycalories_merged;
SET SQL_SAFE_UPDATES = 0;
/* ActivityHour column was 'text' datatype, so I changed it to 'datetime' and renamed it to 'date_time' */
update hourlycalories_merged 
set ActivityHour = str_to_date(ActivityHour, '%m/%d/%Y %h:%i:%s %p');
alter table hourlycalories_merged
change column ActivityHour date_time datetime;

#Table 4 - hourlysteps_merged
describe hourlysteps_merged

/* ActivityHour column was 'text' datatype so I changed it to 'datetime' and renamed it to 'date_time' */

update hourlysteps_merged
set ActivityHour = str_to_date(ActivityHour, '%Y-%m-%d %H:%i:%s');
alter table hourlysteps_merged
change column ActivityHour date_time datetime;

#Table 5 - hourlyintensities_merged 
describe hourlyintensities_merged;
/* ActivityHour column was 'text' datatype, so I changed it to 'datetime' and renamed it to 'date_time' */
update hourlyintensities_merged
set ActivityHour = str_to_date(ActivityHour, '%m/%d/%Y %h:%i:%s %p');
alter table hourlyintensities_merged
change column ActivityHour date_time datetime;

#1 Inspecting 'dailyactivity_merged'
-- select * from dailyactivity_merged;
-- select count(distinct id) as total_users from dailyactivity_merged;        -- 33 users
-- select count(distinct date) as total_days from dailyactivity_merged;        -- 31 days

#2 Inspecting 'sleepday_merged'
select * from sleepday_merged;
select count(distinct id) as total_users from sleepday_merged;        -- 24 users
select count(distinct date_time) as total_days from sleepday_merged;      -- 31 days
#3 Inspecting 'hourlycalories_merged'
-- select * from hourlycalories_merged;
-- select count(*) from hourlycalories_merged;  -- 22099 total records
-- select count(distinct id) as total_users from hourlycalories_merged;        -- 33 users
select count(distinct (date(date_time))) as total_days, 
	   count(distinct (time(date_time))) as total_hours
from hourlycalories_merged;        -- 31 days (containing 24 hours)          

#4 Inspecting 'hourlyintensities_merged'
-- select * from hourlyintensities_merged;
-- select count(*) from hourlyintensities_merged;  -- 22099 total records
-- select count(distinct id) as total_users from hourlyintensities_merged;        -- 33 users
select count(distinct (date(date_time))) as total_days, 
	   count(distinct (time(date_time))) as total_hours
from hourlyintensities_merged;        -- 31 days (containing 24 hours)
 #5 Inspecting 'hourlysteps_merged'
-- select * from hourlysteps_merged;
-- select count(*) from hourlysteps_merged;  -- 22099 total records
-- select count(distinct id) as total_users from hourlysteps_merged;        -- 33 users
select count(distinct (date(datetime))) as total_days, 
count(distinct (time(datetime))) as total_hours from hourlysteps_merged;        -- 31 days (containing 24 hours)

/* finding duplicates in dailyactivity_merged table*/
select id, date, TotalSteps, TotalDistance, TrackerDistance, Calories, count(*)
from dailyactivity_merged
group by id, date, TotalSteps, TotalDistance, TrackerDistance, Calories
having count(*) > 1;            -- 0 Duplicates as the result was empty

/* finding null/missing values in dailyactivity_merged table*/
SELECT
SUM(CASE WHEN id is null or id = 0 then 1 else 0 end) as missing_id,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS Missing_ActivityDate,
    SUM(CASE WHEN TotalSteps = 0 THEN 1 ELSE 0 END) AS Zero_TotalSteps,
    SUM(CASE WHEN TotalDistance = 0 THEN 1 ELSE 0 END) AS Zero_TotalDistance,
    SUM(CASE WHEN TrackerDistance = 0 THEN 1 ELSE 0 END) AS Zero_TrackerDistance,
    SUM(CASE WHEN VeryActiveMinutes = 0 THEN 1 ELSE 0 END) AS Zero_VeryActiveMinutes,
    SUM(CASE WHEN FairlyActiveMinutes = 0 THEN 1 ELSE 0 END) AS Zero_FairlyActiveMinutes,
    SUM(CASE WHEN LightlyActiveMinutes = 0 THEN 1 ELSE 0 END) AS Zero_LightlyActiveMinutes,
    SUM(CASE WHEN SedentaryMinutes = 0 THEN 1 ELSE 0 END) AS Zero_SedentaryMinutes,
    SUM(CASE WHEN Calories = 0 THEN 1 ELSE 0 END) AS Zero_Calories
      from dailyactivity_merged;
/* ID and date column as expected didn't have any missing values, but total_steps column had 77 values as 0 which can't be right because if a person has used the device, he must have walked atleast 1 step that day. So, I removed these entries that had 0 step count. */
delete from dailyactivity_merged where TotalSteps = 0;
/* if totalsteps can't be 0 then calories also can't be zero */
select count(*) from dailyactivity_merged
where Calories = 0;       -- no entries with 0 calories
/* Checking if all the activity minutes add upto 24 hours or 1440 minutes, if not then those values are invalid */
select * from
(
select VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, 
(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) as total_minutes from dailyactivity_merged
  )
    dailyactivity_merged where total_minutes > 1440; -- No invalid values as the output was empty

/* finding duplicates in 'sleepday_merged' table */
select *, count(*) as duplicates from sleepday_merged
group by id, date_time, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
having count(*) > 1;            -- 3 Duplicates
/* Removing duplicates */
/* since ids are also duplicated I added a new column called 'row_num' to give each row a unique identifier, which made it easy to filter out and remove duplicates */
alter table sleepday_merged
add column row_num int auto_increment, add primary key (row_num);
/* deleting duplicates using 'row_num' column */
delete from sleepday_merged
where row_num in (select * from
		(select max(row_num) as rn
			from sleepday_merged
group by id, date_time, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
having count(*) > 1
                  ) sleepday_merged);
/* finding invalid values (values that are greater than 1440 mintues or 24 hours) */
select * from sleepday_merged
where TotalMinutesAsleep > 1440 or TotalTimeInBed > 1440;   -- No invalid values found

/* Adding a new column 'date' from 'date_time' */
alter table sleepday_merged;
-- add column date date after date_time;

update sleepday_merged
set date = date(date_time); 
/* finding duplicates in 'hourlycalories_merged' table*/
select *, count(*) as duplicates from hourlycalories_merged
group by id, date_time, Calories having count(*) > 1;           -- No duplicates were found

/* identifying missing/null values */
select sum(case when id is null or id = 0 then 1 else 0 end) as missing_ids,
       sum(case when date_time is null or date_time = 0 then 1 else 0 end) as missing_dates,
       sum(case when Calories is null or Calories = 0 then 1 else 0 end) as missing_calories
from hourlycalories_merged;         -- No missing or null values were found


/* finding duplicates in ‘hourlyintensities_merged' table*/
select *, count(*) as duplicates from hourlyintensities_merged
group by id, date_time, TotalIntensity, AverageIntensity
having count(*) > 1;           -- No duplicates were found

/* identifying missing/null values */
/*select * from hourlyintensities_merged
where id is null  or id = 0
   or date_time is null or date_time = 0 or
      totalintensity is null or totalintensity = 0 or
      averageintensity is null or averageintensity = 0; */

select sum(case when id is null or id = 0 then 1 else 0 end) as missing_ids,
       sum(case when date_time is null or date_time = 0 then 1 else 0 end) as missing_dates,
       sum(case when TotalIntensity is null or TotalIntensity = 0 then 1 else 0 end) as missing_intensities,
       sum(case when averageintensity is null or averageintensity = 0 then 1 else 0 end) as missing_avg_inensities
from hourlyintensities_merged;         -- '9097' missing values in both 'Totalintensity and AverageIntensity' columns
/* finding duplicates in 'hourlysteps_merged' table */
select *, count(*) as duplicates
from hourlysteps_merged
group by id, datetime, StepTotal
having count(*) > 1;           -- No duplicates

/* identifying missing/null values */
select sum(case when id is null or id = 0 then 1 else 0 end) as missing_ids,
       sum(case when datetime is null or datetime = 0 then 1 else 0 end) as missing_dates,
       sum(case when steptotal is null or steptotal = 0 then 1 else 0 end) as missing_steptotal
from hourlysteps_merged;         -- '9297' missing values in 'Steptotal' column
/*The next step was to transform the data and do further analysis */
/* I combined data from tables containing data related to daily activity (dailyactivity_merged, dailysleep_merged) into a new table called 'daily_activity_sleep' and tables containing hourly data (hourlycalories_merged, hourlyintensities_merged, hourlysteps_merged) into a new table called 'hourly_activity' */
-- combining tables 'dailyactivity_merged' and 'dailysleep_merged'
create table daily_activity_sleep
select tbl1.*, tbl2.TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
from dailyactivity_tbl  tbl1
join dailysleep_tbl     tbl2  using(id, date);
/* the above table had data for '24 users' */

/*Next, I created one table of hourly_activity by merging all the hourly data tables. For that first I had to rename a column name datetime in the hourly steps table as date_time to match all the column names with the other hourly tables.*/
-- combining 'hourlycalories_merged' , 'hourlyintensities_merged' and 'hourlysteps_merged'
create table hourly_activity
select tbl1.*, tbl2.TotalIntensity, tbl2.AverageIntensity, tbl3.StepTotal
from hourlycalories_merged      tbl1
join hourlyintensities_merged   tbl2    using (id, date_time)
join hourlysteps_merged         tbl3    using (id, date_time);


/* Adding a new column 'day' to 'daily_activity_sleep', 'dailyactivity_merged', 'hourly_activity' */
#1 adding day column to 'daily_activity_sleep'
SET SQL_SAFE_UPDATES = 0;
alter table daily_activity_sleep
add column day varchar(10) after date;
update daily_activity_sleep
set day = dayname(date);

#2 adding day column to 'dailyactivity_merged'
SET SQL_SAFE_UPDATES = 0;
alter table dailyactivity_merged
add column day varchar(10) after date;
update dailyactivity_merged
set day = dayname(date);

#3 adding day column to 'hourly_activity'
SET SQL_SAFE_UPDATES = 0;
alter table hourly_activity
add column day varchar(10) after date_time;
update hourly_activity
set day = dayname(date_time);

/* Adding a new column 'total_active_minutes' in these 2 tables */
#1 adding 'total_active_minutes' column to 'daily_activity_sleep'
/*SET SQL_SAFE_UPDATES = 0;
alter table daily_activity_sleep
add column total_active_minutes int after totalsteps; */
UPDATE daily_activity_sleep
SET total_active_minutes = veryactiveminutes + fairlyactiveminutes + lightlyactiveminutes;

#2 adding 'total_active_minutes' column to 'dailyactivity_merged'
/*SET SQL_SAFE_UPDATES = 0;
alter table dailyactivity_merged
add column total_active_minutes int after totalsteps; */
UPDATE dailyactivity_merged
SET total_active_minutes = veryactiveminutes + fairlyactiveminutes + lightlyactiveminutes;

/* Adding a new column 'total_active_minutes' in 'daily_activity_sleep'*/
/*SET SQL_SAFE_UPDATES = 0;
alter table daily_activity_sleep
add column minutes_awake int ; */
UPDATE daily_activity_sleep
SET minutes_awake = totaltimeinbed - totalminutesasleep;

/* Removing distance related columns, as they don't much info about usage preferences 
   or health profile, because for that we have totalsteps and activity minutes data */
  
#1 removing distance columns from 'daily_activity_sleep'
SET SQL_SAFE_UPDATES = 0;
alter table daily_activity_sleep
drop column TotalDistance,
drop column TrackerDistance;

#2 removing distance columns from 'dailyactivity_merged'
SET SQL_SAFE_UPDATES = 0;
alter table dailyactivity_merged
drop column TotalDistance,
drop column TrackerDistance;
/* FINAL COMPLETE TABLES */
select * from daily_activity_sleep;
select * from dailyactivity_merged;
select * from hourly_activity;

-- ANALYSIS
-- Device usage Analysis
#1 Total users of each feature
select count(distinct id) as sleeptracker_users, 
       count(distinct id) as activitytracker_users
from daily_activity_sleep;          -- 24 users
select count(distinct id) as activitytracker_users
from dailyactivity_merged;             -- 33 users

#2 Device usage level
select id, days_used,  
	   case when days_used between 1 and 10 then 'Seldom'
            when days_used between 10 and 25 then 'Very Often'
            when days_used > 25 then 'Regular'
            else 'Wrong'
            end as usage_type
from (
		select id, count(date) as days_used
		from dailyactivity_merged
		group by id
		order by days_used desc
	 ) dailyactivity_merged
group by id, days_used;

#3 User average active minutes during the week.
/*For this, I just used Tableau Public and used the dailyactivity_merged table to draw this dual chart.*/
#4 sedentary vs active during the month
/*For this, I just used Tableau Public and used the dailyactivity_merged table to draw this dual chart.*/
#5 usage rate by day of the week
select day, day_num, round(avg(total_users),2) as avg_users
from (
		select date, weekday(date)+1 as day_num, day, count(*) as total_users
		from dailyactivity_merged
		group by date, day
        order by date, day_num
	 )dailyactivity_merged
group by day, day_num
order by day_num;

#6 Average steps taken by hour and days of the week
select (row_number() over (partition by day order by hour))-1 as hour_num,
       day, day_num, hour, round(avg(total_steps),2) as avg_steps
from (
		select id, day, weekday(date_time)+1 as day_num, time(date_time) as hour, sum(StepTotal) as total_steps
		from hourly_activity
		group by id, day, hour, day_num
        order by day_num
	 )hourly_activity
group by day, hour, day_num
order by day_num, hour_num;

#7 Average time in bed by day
select day, avg(TotalMinutesAsleep), avg(TotalTimeInBed), avg(minutes_awake)
from daily_activity_sleep
group by day;

#Some extra queries that I used for drawing graphs.
#Classifying Users with respect to their Average_Daily_Steps
#Average by users
#Step 1: For that purpose, I first created a table to use it in the next steps.

Create Table AverageByUsers
SELECT id,  
round(avg(TotalSteps), 2) AS Avg_Daily_Steps, 
round(avg(TotalMinutesAsleep), 0) AS Avg_Sleep,
round(avg(Calories), 0) AS Avg_Calories
FROM
daily_activity_sleep
GROUP BY id;

#Step 2:  I created another table to use it in the next step by using the table which i created in step 1.

CREATE TABLE user_classification_by_avg_daily_steps
SELECT id, AVG_Daily_Steps,
(CASE
WHEN AVG_Daily_Steps < 5000 THEN "Sedentary"
WHEN AVG_Daily_Steps >= 5000 AND AVG_Daily_Steps < 7499 THEN "Lighlity Active"
WHEN AVG_Daily_Steps >= 7500 AND AVG_Daily_Steps < 9999 THEN "Fairly Active"
WHEN AVG_Daily_Steps >= 10000 THEN "Very Active"
END) AS User_Type
FROM AverageByUsers;


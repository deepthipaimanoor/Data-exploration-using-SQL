-- to view if all the data is successfully uploaded into the database
select *
from Covid_Death
order by 3,4

select *
from Covid_Vaccinations
order by 3,4

-- select data we are using i.e covid death

select location, date,total_cases, new_cases, total_deaths, population
from Covid_Death
order by 1,2

-- change the datatype of total_cases, total_death to float
ALTER TABLE Covid_Death
alter column new_cases float

select convert(FLOAT,total_cases)
from covid_death

select cast(new_deaths as float)
from covid_death


-- looking at percentage of death due to covid cases
select location, date,total_cases,total_deaths,(total_deaths/ total_cases)*100 AS death_percentage
from Covid_Death
where continent is not null
order by 1,2

--select united states as location
select location, [date], total_cases,total_deaths, ((total_deaths/total_cases)*100) as death_percentage
from Covid_Death
where [location] like '%states%'
order by 1,2

--total cases per country select united states as location daily basis ordered by highest percentage
select location, [date], population, total_cases, ((total_cases/population)*100) as case_rate
from Covid_Death
where [location] like '%states%'
order by 5 desc;

-- total cases per country
select location, sum(total_cases) as totalcases, max(population) as populationstat, (sum(total_cases)/max(population))*100 as case_rate_country
from Covid_Death
where continent is not null
group by [location]
order by [location];


-- top 10 countries with total number of infection rate till date
select top 10 location, population, sum(total_cases) as case_stat, (sum(total_cases)/max(population))*100 as case_rate
from Covid_Death
where continent is not null
group by [location], population
order by [case_rate] desc

--  top 10 countries with total number of hightest infection rate
select top 10 [location], population, max(total_cases) as case_stat, (max(total_cases)/ population)*100 as case_rate
from Covid_Death
where continent is not null
group by [location], population
order by case_rate desc



--  top 10 countries with highest death rate
select top 10 [location], population, max(total_cases) as case_stat, max(total_deaths) as death_stat,(max(total_cases)/ population)*100 as case_rate, (max(total_deaths)/population)*100 as death_rate
from Covid_Death
where continent is not null
group by [location], population
order by death_stat desc

-- breaking things into continent
select [location], max(total_deaths) as death
from covid_death
where continent is null
group by [location]
order by death desc

--- showing continents with highest death count
select location, max(total_deaths) as death_stat
from Covid_Death
where continent lIKE 'EUROPE'
group by location
order by death_stat desc

--- showing locations under europe with highest death count
select location, max(total_deaths) as death_stat
from Covid_Death
where continent lIKE 'EUROPE'
group by location
order by death_stat desc


-- global number
select sum(new_cases) as case_total, sum(new_deaths) as death_total, sum(new_deaths)/sum(new_cases)*100 as case_death_stat
from Covid_Death
where continent is not null
--group by date
order by 1,2

select date, sum(new_cases) as case_total, sum(new_deaths) as death_total, sum(new_deaths)/sum(new_cases)*100 as case_death_stat
from Covid_Death
where continent is not null
group by date
order by 1,2



-- lets see the second table again
select *
from Covid_Death
select *
from Covid_Vaccinations

-- joining the tables
select * 
from Covid_Death cd
join Covid_Vaccinations cv
on cd.location = cv.location and cd.date = cv.date;

-- total population vs vaccination
select cd.continent, cd.location, cd.date, cd.population , cv.new_vaccinations
from Covid_Death as cd
join covid_vaccinations as cv
on cd.location =cv.location 
and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- using partition by
select cd.continent, cd.location, cd.date, cv.new_vaccinations, sum(new_vaccinations) over (PARTITION BY cd.LOCATION order by cd.LOCATION,cd.date)
from Covid_Death as cd
join Covid_Vaccinations as cv
on cd.location =cv.location and cd.date =cv.date
where cd.continent is not null
order by 1,2,3

-- This provides information on when vaccinations commenced, the initial case rate, and the subsequent increase over time.
select cd.location, cd.date, cd.new_cases, sum(cd.new_cases) over (partition by cd.location order by cd.location,cd.date) as totalcasehit,  cv.new_vaccinations,sum(cv.new_vaccinations) over (partition by cv.location order by cv.location,cv.date) as totalvaccinehit
from Covid_Death as cd
join Covid_Vaccinations as cv
on cd.location =cv.location and cd.date=cv.date
where cd.continent is null
order by 1, 2

--- parition by newdeath
select cd.location,cd.date,cd.new_deaths, sum(cd.new_deaths) over (partition by cd.location order by cd.location, cd.date) as totaldeathhit
from Covid_Death as cd
join Covid_Vaccinations as cv
on cd.location =cv.location and cv.date=cd.date
order by 1,2


--- CREATING A NEW TABLE
create table Covid_Case
(continent varchar(50),
location varchar(50),
date date,
population FLOAT,
New_case float,
Total_case float,
Total_vaccine float
)


--- INSERT DATA INTO THE TABLE
insert into Covid_Case
select cd.continent as Continent, cd.location as Location, cd.date as Date, cd.population as Population, cd.new_cases, sum(cd.new_cases) over (partition by cv.location order by cv.location,cv.date) as Total_Case, sum(cv.Total_vaccinations) over (partition by cv.total_vaccinations order by cv.location, cv.date)
from Covid_Death as cd
join Covid_Vaccinations as cv
on cd.location =cv.location and cd.date=cv.date

--- VIEW THE TABLE
select *
from covid_case
order by location, DATE

--- drop table covid_case
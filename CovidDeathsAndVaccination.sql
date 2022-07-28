create database portfolioproject;
use portfolioproject;
update coviddeaths set continent=NULL where continent='';
update coviddeaths set total_deaths=0 where total_deaths='';

select * from coviddeaths;
select * from covidvaccinations;

-- Total Cases V/s New Cases in India:
select location,date,total_cases, new_cases, (new_cases/total_cases)*100 as new_cases_percent
from coviddeaths
where location='India'
order by new_cases_percent;

-- Total cases vs population in India:
select location,date,total_cases,population, (total_cases/population)*100 as total_cases_percent
from coviddeaths
where location='India';

-- Highest number of new cases and Total cases in India in a day:
select location, max(total_cases) as Highest_Total_Cases, max(new_cases) as Highest_New_Cases
from coviddeaths
where location='India';

select location, date , total_cases
from coviddeaths
where location ='india' and total_cases = (select max(total_cases) from coviddeaths where location ='India');

select location, date , new_cases
from coviddeaths
where location ='India' and new_cases = (select max(new_cases) from coviddeaths where location ='India');

-- Total deaths vs Total cases in India:
select location, date,total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage
from coviddeaths
where location='India'
order by Death_Percentage desc;

-- Maximum number of cases and deaths in all country:
select location, max(total_cases) as 'Highest Cases', max(total_deaths) as HighestDeaths
from coviddeaths
where continent is not null
group by location 
order by HighestDeaths desc;

-- Covid infection Rate:
select location, population, max(total_cases/population)*100 as InfectionRate
from coviddeaths
where continent is not null
group by location
order by InfectionRate desc;

-- Covid Death Rate:
select location, population, max(total_deaths/total_cases)*100 as InfectiveDeathRate,max(total_deaths/population)*100 as DeathRate
from coviddeaths
where continent is not null
group by location
order by DeathRate desc;


-- The continents with highest death counts:
select location, max(total_deaths) as deaths
from coviddeaths
where continent is null
group by location 
order by deaths desc;

-- New Cases and new deaths date wise
select date, sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths 
group by date
order by DeathPercentage desc;

-- Overall death percentage in the world:
select sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths 
order by DeathPercentage desc;


-- Joining the two table
select *
from coviddeaths cod
join 
covidvaccinations vac
on cod.location=vac.location
and cod.date=vac.date;

-- Total population vs vaccinations
select cod.continent,cod.location,cod.date,cod.population,vac.new_vaccinations
from coviddeaths cod
join 
covidvaccinations vac
on cod.location=vac.location
and cod.date =vac.date
where cod.continent is not null;

-- Summing new vaccinations on daily basis
select cod.continent,cod.location,cod.date,cod.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) over(partition by cod.location order by cod.date) as Daily_Vaccination
from coviddeaths cod
join 
covidvaccinations vac
on cod.location=vac.location
and cod.date =vac.date
where cod.continent is not null;


-- CTE or WITH Clause:
WITH population_vaccinations
as
(select cod.continent,cod.location,cod.date,cod.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) over(partition by cod.location order by cod.date) as Daily_Com_Vaccination
from coviddeaths cod
join 
covidvaccinations vac
on cod.location=vac.location
and cod.date =vac.date
where cod.continent is not null)
select *, (Daily_Com_Vaccination/population)*100 as Percentage_Vaccinations
from population_vaccinations;

-- Temp Table:
drop table if exists PopulationVaccinated
create temporary table PopulationVaccinated
(continent text,
        location text,
        date date,
        population int,
        new_vaccinations text,
        Daily_Com_Vaccination numeric)
Insert into PopulationVaccinated
(select cod.continent,cod.location,cod.date,cod.population,vac.new_vaccinations, 
sum(vac.new_vaccinations) over(partition by cod.location order by cod.date) as Daily_Com_Vaccination
from coviddeaths cod
join 
covidvaccinations vac
on cod.location=vac.location
and cod.date =vac.date
where cod.continent is not null)

select *, (Daily_Com_Vaccination/population)*100 as Percentage_Vaccinations
from PopulationVaccinated;

-- Creating view to store data:
create view ContinentsAffected as
select location, max(total_deaths) as deaths
from coviddeaths
where continent is null
group by location 
order by deaths desc;

select * from ContinentsAffected;
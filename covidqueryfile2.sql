

-- select some data for review
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project..['coviddeaths']
order by 1,2 

-- select data from vaccination sheet
select location, new_vaccinations, date, continent
from Portfolio_project..['Covidvaccination']
order by 1, 3

-- total cases versus total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_project..['coviddeaths']
order by 1,2 

-- total cases versus total deaths for Nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_project..['coviddeaths']
where location like '%Nigeria%'
order by 1,2 

--total cases vs population
select location, date, population, total_cases, (total_deaths/population)*100 as PopulationPercentage
from Portfolio_project..['coviddeaths']
--where location like '%Nigeria%'
order by 1,2 


--highest infection rate
select location, population, MAX(total_cases) as HighestInfectionCOunt, MAX((total_deaths/population))*100 as PopulationPercentage
from Portfolio_project..['coviddeaths']
--where location like '%Nigeria%'
group by location, population
order by PopulationPercentage desc


--highest infection rate ascending order
select location, population, MAX(total_cases) as HighestInfectionCOunt, MAX((total_deaths/population))*100 as PopulationPercentage
from Portfolio_project..['coviddeaths']
--where location like '%Nigeria%'
group by location, population


--countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_project..['coviddeaths']
group by location
order by TotalDeathCount desc


--countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_project..['coviddeaths']
where continent is not null
group by location
order by TotalDeathCount desc


-- deaths by continents
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_project..['coviddeaths']
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
select sum(total_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as TotalDeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_project..['coviddeaths']
where continent is not null
---group by date
order by 1,2 

select date, sum(total_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(cast(new_deaths as int))*100 as TotalDeathPercentage 
from Portfolio_project..['coviddeaths']

group by date
order by 1,2 


select *
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project.. ['Covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date


--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project.. ['covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as VaccineGiven
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project..['Covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--looking at total population vaccination percentage using CTE
with pop_vac (continent, location, date, population, new_vaccinations, VaccineGiven)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as VaccineGiven
--(VaccineGiven)/(dea.population)*100
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project..['Covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (VaccineGiven/population)*100 as PercentageVaccinated
from pop_vac


--looking at total population vs vaccination using temp table

drop table if exists #populationvaccinatedpercentage
create table #populationvaccinatedpercentage
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	vaccinegiven numeric
	)
insert into #populationvaccinatedpercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as VaccineGiven
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project..['Covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (VaccineGiven/population)*100 as PercentageVaccinated
from #populationvaccinatedpercentage

--creating veiw to store data

create view populationvaccinatedpercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as VaccineGiven
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project..['Covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- view for covid vaccination
create view CovidvaccineReview
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio_project.. ['coviddeaths'] dea
join Portfolio_project.. ['covidvaccination'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
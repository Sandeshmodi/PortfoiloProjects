
select *
From PortfolioProject..coviddeaths
where continent is not null
order by 3, 4


select *
From PortfolioProject..covidvaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
order by 1, 2

-- looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathprecentage
From PortfolioProject..coviddeaths
where location like '%india%'
and continent is not null
order by 1, 2


--Looking at total cases vs population
-- shows what percentage of population got Covid

select location, date, population,  total_cases, (total_cases/population)*100 as Percentpopulationinfected
From PortfolioProject..coviddeaths
where location like '%india%'
and where continent is not null
order by 1, 2

--Looking at countries with highest infection rate compared to population

select location, population,  MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as Percentpopulationinfected
From PortfolioProject..coviddeaths
--where location like '%india%'
and where continent is not null
group by location, population
order by Percentpopulationinfected desc

-- countries with highest death count vs population

select location, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..coviddeaths
--where location like '%india%'
where continent is not null
group by location
Order by Totaldeathcount desc

--Lets break things down by continent

-- Showing continents with highest death count per population


select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..coviddeaths
--where location like '%india%'
where continent is not null
group by continent
Order by Totaldeathcount desc


--GLOBAL Numbers per day

select  date, SUM(new_cases) as Total_cases, Sum(Cast(new_deaths as int)) as Total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 Deathprecentage
From PortfolioProject..coviddeaths
--where location like '%india%'
where continent is not null
Group by date
order by 1, 2

--Global Number Total

select   SUM(new_cases) as Total_cases, Sum(Cast(new_deaths as int)) as Total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 Deathprecentage
From PortfolioProject..coviddeaths
--where location like '%india%'
where continent is not null
order by 1, 2


--Looking for total Population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order BY dea.location, dea.date) as Totalpeoplevaccinated
From PortfolioProject..covidvaccinations vac
JOIN PortfolioProject..coviddeaths dea
 ON vac.location = dea.location
 AND vac.date = dea.date
 where dea.continent is not null
 order by 2, 3

 --USE CTE

 With popvsvac (continent, location, date, population, new_vaccination, Totalpeoplevaccinated)
 as
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order BY dea.location, dea.date) as Totalpeoplevaccinated
From PortfolioProject..covidvaccinations vac
JOIN PortfolioProject..coviddeaths dea
 ON vac.location = dea.location
 AND vac.date = dea.date
 where dea.continent is not null
 --order by 2, 3
 )
 select * , ( Totalpeoplevaccinated /population)*100
 from popvsvac

 
 
 --Temp table

 drop table if exists #percentpopulationvaccinated

 create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date Datetime,
 population numeric,
 new_vaccinations numeric,
 Totalpeoplevaccinated numeric
 )

 insert into #percentpopulationvaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order BY dea.location, dea.date) as Totalpeoplevaccinated
From PortfolioProject..covidvaccinations vac
JOIN PortfolioProject..coviddeaths dea
 ON vac.location = dea.location
 AND vac.date = dea.date
 where dea.continent is not null
 --order by 2, 3

select * , ( Totalpeoplevaccinated /population)*100
 from #percentpopulationvaccinated


 -- creating view to store data forlater visualizations

 create view percentpopulationvaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order BY dea.location, dea.date) as Totalpeoplevaccinated
From PortfolioProject..covidvaccinations vac
JOIN PortfolioProject..coviddeaths dea
 ON vac.location = dea.location
 AND vac.date = dea.date
 where dea.continent is not null
 --order by 2, 3

 select *
 from percentpopulationvaccinated

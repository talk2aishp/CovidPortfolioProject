SELECT location,date,population,total_cases,new_cases,total_deaths
FROM CovidDeaths
WHERE location is not null
order by 1,2

--Total Cases vs Total Deaths to find death %

--SELECT location,date,total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
--FROM CovidDeaths
--where location = 'India'
--order by 2

-- Finding % of population got covid in a location

--SELECT location,date, population, total_cases, (total_cases/population)*100 as Covid_positive_percentage
--FROM CovidDeaths
--where location = 'India'
--order by 2

--Countries with higher infection for their population

--SELECT location,population, max(total_cases) max_cases, (max(total_cases)/population)*100 as Covid_positive_percentage
--FROM CovidDeaths
--group by location,population
--order by 4 desc

--countries with highest deaths for their population
SELECT location,population, max(total_deaths) max_deaths, (max(total_deaths)/population)*100 as Covid_death_percentage_forPopulation
FROM CovidDeaths
WHERE continent is not null
--where location like 'United%'
group by location,population
order by 4 desc

-- total deaths in each continent

SELECT continent, max(CAST(total_deaths AS INT)) as max_deaths
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
order by 2 desc

-- Global Death Percentage

SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as global_death_percentage
FROM CovidDeaths
where continent is not null
--group by date
order by 1,2 desc

-- Looking at total population vs vaccinations
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,dea.date) rolling_ppl_vaccination_count 
FROM CovidDeaths dea
join covidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

--Looking to find total population vaccination %
--using CTE
WITH popvsvac
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,dea.date) rolling_ppl_vaccination_count 
FROM CovidDeaths dea
join covidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

SELECT *,(rolling_ppl_vaccination_count/population)*100 Vaccination_Percentage
FROM popvsvac
order by 1,2,3

--Using TempTable
--DROP TABLE if exists #VaccinationPercentagePerPopulation
CREATE TABLE #VaccinationPercentagePerPopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_ppl_vaccination_count numeric
)

INSERT INTO #VaccinationPercentagePerPopulation
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,dea.date) rolling_ppl_vaccination_count 
FROM CovidDeaths dea
join covidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

SELECT *,(rolling_ppl_vaccination_count/population)*100 Vaccination_Percentage
FROM #VaccinationPercentagePerPopulation
order by 1,2,3

-- Creating views for Data Visualizaztion

CREATE VIEW vw_PercentPopulationVaccinated
as
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as INT)) over (partition by dea.location order by dea.location,dea.date) rolling_ppl_vaccination_count 
FROM CovidDeaths dea
join covidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from vw_PercentPopulationVaccinated
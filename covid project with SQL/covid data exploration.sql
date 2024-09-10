SELECT *
FROM [portfolio project ]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM [portfolio project ]..CovidVaccinations$
--ORDER BY 3,4

--looking at total cases vs total death
--shows liklehood of dying if contract a covid in your country
SELECT location, date, total_Cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM [portfolio project ]..CovidDeaths$
WHERE location like '%egypt%' and 
 continent IS NOT NULL
ORDER BY 1, 2

 --looking at total cases vs population
 -- shows the percentage of population got covid

 SELECT location, date, total_Cases,population, (total_cases/population)*100 as percentPopulationInfected
FROM [portfolio project ]..CovidDeaths$
WHERE location like '%egypt%'
ORDER BY 1, 2 

--looking for the countries with the highiest infection rate compared to population

 SELECT location, max (total_Cases),population , max((total_cases/population))*100 as percentPopulationInfected
FROM [portfolio project ]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY  location,population
ORDER BY percentPopulationInfected desc

--let's break thinbgs down by continent

 SELECT continent, max (cast (total_deaths as int))as total_death_count
FROM [portfolio project ]..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY  continent
ORDER BY total_death_count desc

--showing countries with highest death count per population
--دي واللي فوقيها يعتبروا نفس الحاجه

 SELECT location, max (cast (total_deaths as int))as total_death_count
FROM [portfolio project ]..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY  location
ORDER BY total_death_count desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,  SUM(cast(new_deaths as int))/SUM(new_cases) *100 as death_percentage
FROM [portfolio project ]..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
GROUP BY  date
ORDER BY 1,2
--كل اللي فات دا كان عن الداتاسيت بتاعه ال covid_deaths

SELECT *
FROM [portfolio project ]..CovidVaccinations$

--looking at total population vs vaccination:

SELECT*
FROM [portfolio project ]..CovidVaccinations$  vac
JOIN [portfolio project ]..CovidDeaths$  dea
ON dea.location=vac.location
AND dea.date=vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [portfolio project ]..CovidVaccinations$  vac
JOIN [portfolio project ]..CovidDeaths$  dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea. continent IS NOT NULL
ORDER BY dea.continent , dea.location

--using cte 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [portfolio project ]..CovidVaccinations$  vac
JOIN [portfolio project ]..CovidDeaths$  dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea. continent IS NOT NULL
--ORDER BY dea.continent , dea.location
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [portfolio project ]..CovidVaccinations$  vac
JOIN [portfolio project ]..CovidDeaths$  dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea. continent IS NOT NULL
ORDER BY dea.continent , dea.location

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [portfolio project ]..CovidVaccinations$  vac
JOIN [portfolio project ]..CovidDeaths$  dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea. continent IS NOT NULL
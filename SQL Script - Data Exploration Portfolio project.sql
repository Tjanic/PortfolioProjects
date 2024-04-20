SELECT * 
FROM CovidVaccinations

SELECT *
FROM PortfolioProject..CovidDeaths



-- Select the Data we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if one contracts covid in the United Kingdom
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United Kingdom'

-- Looking at Total cases vs Population
-- Shows the percentage of population who contracted Covid in the United Kingdom
SELECT Location, date,population, total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United Kingdom'

--Looking at which country had the higher infection rate compared to population
SELECT Location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population 
ORDER BY PopulationPercentageInfected DESC

-- Showing which country had the higher death count per population
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Now to break it down by continent
SELECT continent, MAX(total_deaths) as TotalDeathCountContinent
FROM PortfolioProject..CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCountpercont DESC

-- Looking at which continent had the higher case of Covid
SELECT location, continent, MAX(total_cases)
FROM PortfolioProject..CovidDeaths
GROUP BY LOCATION,continent
ORDER BY MAX(total_cases) DESC

-- Looking at which continent had a higher death rate
SELECT continent, MAX(total_deaths/total_cases)*100 AS DeathPercentageContinent
FROM PortfolioProject..CovidDeaths
GROUP BY continent
ORDER BY MAX(total_deaths/total_cases)*100 desc

--Looking at which continent had a higher infection rate
SELECT continent, MAX(total_cases/population)*100 AS InfectionPercentageContinent
FROM PortfolioProject..CovidDeaths
GROUP BY continent
ORDER BY InfectionPercentageContinent desc

-- United Kingdom & United States numbers combined death percentage
SELECT SUM(New_cases) as totalCases, SUM(new_deaths) as totalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--GROUP BY date
Order by 1,2

-- Looking at total population vs vaccination
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date

-- Rolling count of vaccinations per day per country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date

-- Using CTE
WITH Popvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM Popvac

-- Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Rolling count of deaths per day per country
SELECT continent, location, date, population, new_deaths, 
SUM(new_deaths) OVER (Partition by continent, location order by date) AS Deathrolling
FROM CovidDeaths

-- Percentage of people dying per day per country (Using CTE)
WITH Deapop (Continent, location, date, population, new_deaths, Deathrolling)
AS
(
SELECT continent, location, date, population, new_deaths, 
SUM(new_deaths) OVER (Partition by continent, location order by date) AS Deathrolling
FROM CovidDeaths
)
SELECT *, (Deathrolling/Population)*100
FROM Deapop

-- Using Temp table
DROP TABLE IF EXISTS #PercentDEATHPOPULATION
CREATE TABLE #PercentDeathPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_deaths numeric,
deathrolling numeric
)
INSERT INTO #PercentDeathPopulation
SELECT continent, location, date, population, new_deaths, 
SUM(new_deaths) OVER (Partition by continent, location order by date) AS Deathrolling
FROM CovidDeaths

SELECT *, (Deathrolling/Population)*100
FROM #PercentDeathPopulation

-- Creat view to store data for later visualisation
CREATE VIEW Deathrolling AS
SELECT continent, location, date, population, new_deaths, 
SUM(new_deaths) OVER (Partition by continent, location order by date) AS Deathrolling
FROM CovidDeaths

CREATE VIEW RollingPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date




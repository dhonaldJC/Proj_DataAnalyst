---TRY AGAIN SUBMIT



-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE [location] like '%indonesia%'
AND continent IS NOT NULL
ORDER BY 1,2


-- try to commit again
-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT TOP(100) location, date, population, total_cases, (total_cases / population)*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE [location] like '%indonesia%'
AND continent IS NOT NULL
ORDER BY 1 , 2



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
    MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
-- WHERE [location] like '%indonesia%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with Highest Deat Count Per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
-- WHERE [location] like '%indonesia%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
-- WHERE [location] like '%indonesia%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, 
        SUM(CAST(new_deaths as int)) AS Total_deaths, 
        SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric(12, 0))) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE

WITH PopvsVac ( Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated )
as
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(cast(vac.new_vaccinations as numeric(12, 0))) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
    --, (RollingPeopleVaccinated/population)*100
    From PortofolioProject..CovidDeaths dea
    JOIN PortofolioProject..CovidVaccinations vac
    	ON dea.location = vac.location
	    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    -- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/ Population)*100
FROM PopvsVac



-- TEMP Tabel

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Data DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric(12, 0))) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

SELECT * , (RollingPeopleVaccinated/ Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric(12, 0))) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated
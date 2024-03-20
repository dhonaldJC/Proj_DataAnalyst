/*

Queries used for Tableau Project

*/


-- 1. 

SELECT SUM(new_cases) AS Total_cases, 
        SUM(CAST(new_deaths as int)) AS Total_deaths, 
        SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2



-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- SELECT  SUM(new_cases) as total_cases,
        -- SUM(cast(new_deaths as int)) as total_deaths, 
        -- SUM(cast(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
-- FROM PortofolioProject..CovidDeaths
-- --WHERE location like '%indonesia%'
-- WHERE location = 'World'
-- --GROUP BY date
-- ORDER BY 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3.

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  
        Max((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- 4.


SELECT Location, Population, date, MAX(total_cases) as HighestInfectionCount,  
        Max((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

SELECT  dea.continent, dea.location, dea.date, dea.population, 
        MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3




-- 2.
SELECT  SUM(new_cases) as total_cases, 
        SUM(cast(new_deaths as int)) as total_deaths, 
        SUM(cast(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- SELECT  SUM(new_cases) as total_cases,
        -- SUM(cast(new_deaths as int)) as total_deaths, 
        -- SUM(cast(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
-- FROM PortofolioProject..CovidDeaths
-- --WHERE location like '%indonesia%'
-- WHERE location = 'World'
-- --GROUP BY date
-- ORDER BY 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent IS NULL 
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc



-- 4.

SELECT Location, Population, 
        MAX(total_cases) as HighestInfectionCount, 
        Max((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc



-- 5.

--SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortofolioProject..CovidDeaths
----WHERE location like '%indonesia%'
--WHERE continent IS NOT NULL
--ORDER BY 1,2

-- took the above query and added population
SELECT Location, date, population, total_cases, total_deaths
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 as PercentPeopleVaccinated
FROM PopvsVac


-- 7. 

SELECT  Location, Population, date, 
        MAX(total_cases) as HighestInfectionCount,
        Max((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc




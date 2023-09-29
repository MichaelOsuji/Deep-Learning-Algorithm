/* 

Covid 19 Data Exploration

Utilized joins, Aggregate functions, CTE's, Temp tables, Converting Data types

*/


SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4


-- SHOWING THE DEATH PERCENTAGE IN NIGERIA IN ORDER OF DATES

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2




-- COUNTRIES WITH THE HIGHEST INFECTION RATE

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income') 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC




-- COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC




--CATEGORIZING BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC




-- CONTINENTS WITH THE HIGHEST DEATH COUNTS

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC




-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
CASE
   WHEN SUM(new_cases) = 0 THEN NULL
 ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100
END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2 




-- TOTAL DEATH PERCENTAGE ACROSS THE WORLD

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
CASE
   WHEN SUM(new_cases) = 0 THEN NULL
 ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100
END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2 




-- POPULATION AGAINST VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




-- TOTAL POPULATION VACCINATED

SELECT dea.location, dea.population, MAX(CAST(people_vaccinated as bigint)) as TotalPopulationVaccinated, 
(MAX(CAST(people_vaccinated as bigint))/population)*100 as PercentVaccinatedPopulation
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
WHERE dea.continent IS NULL
AND dea.location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income')
GROUP BY dea.location, dea.population
ORDER BY PercentVaccinatedPopulation DESC





-- USE CTE TO CALCULATE THE PERCENT VACCINATED ON Partition by

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
)
select *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopvsVac





-- USING TEMP TABLE TO PERFORM THE QUERY ABOVE ON Partition by

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and Dea.date = Vac.date
--WHERE dea.continent IS NOT NULL

select *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated




--CREATING VIEW TO STORE DATA FOR VISUALIZATION

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

select *
from PercentPopulationVaccinated

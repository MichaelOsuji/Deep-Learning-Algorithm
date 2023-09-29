SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4


-- This Shows the Death Percentage in Nigeria in order of dates

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2




-- Looking at Countries with the highest infection rate

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income') 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC




-- Showing countries with the highest Death count per population

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




-- Showing the continents with the highest death counts

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




-- Total Death Percentage across the World

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
CASE
   WHEN SUM(new_cases) = 0 THEN NULL
 ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100
END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2 




-- Looking at Total population against Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	and Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3





-- Looking at the Total population Vaccinated

SELECT dea.location, dea.population, MAX(CAST(people_vaccinated as bigint)) as TotalPopulationVaccinated, 
(MAX(CAST(people_vaccinated as bigint))/population)*100 as PercentVaccinatedPopulation
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
WHERE dea.continent IS NULL
AND dea.location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Low income', 'Lower middle income')
GROUP BY dea.location, dea.population
ORDER BY PercentVaccinatedPopulation DESC





-- USE CTE to find percent Vaccinated

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





-- USING TEMP TABLE

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




--Creating View To store Data for Visualization

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
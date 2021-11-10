SELECT *
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccionations 
--order by 3,4

-- Select the Data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
ORDER BY 1,2

-- Loking at Total Cases vs Total Deaths
-- Likelihood of dieing if you contract covid per country per time
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE location like '%uruguay%'
and continent is not null
ORDER BY 1,2

--Looking at total cases against population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths 
WHERE location like '%uruguay%'
and continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rates
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectedPercentage desc

--Looking at countries with highest deaths

-- Careful, it is important to change the data type, that is what the cast as int does
SELECT Location, MAX(cast(Total_deaths as int)) as HighestDeathCount --, MAX(cast(Total_deaths as int)/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY Location
ORDER BY HighestDeathCount desc


-- LET'S DO IT BY CONTINENT

-- Careful, it is important to change the data type, that is what the cast as int does
SELECT continent, MAX(cast(Total_deaths as int)) as HighestDeathCount --, MAX(cast(Total_deaths as int)/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- Continents with highest death per pop

SELECT continent, MAX(total_deaths) as HighestDeathsCount, MAX(total_deaths/population)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY DeathsPercentage desc

--GLOBAL NUMBERS (not by region)

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%uruguay%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccinations

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
, RollingPeopleVaccinated/population*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE (Common Table Expression)

WITH PopvsVac (continent, location, date, population, new_vaccionations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population*100)
FROM PopvsVac




--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccionated
CREATE TABLE #PercentPopulationVaccionated
( 
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccionations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccionated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population*100)
FROM #PercentPopulationVaccionated


--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccionated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccionated
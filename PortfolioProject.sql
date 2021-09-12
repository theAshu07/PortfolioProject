SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 DESC

-- Looking at total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India'
ORDER BY 1,2;

SELECT location, date, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE location like '%India'
ORDER BY total_deaths DESC;

-- Looking at total_cases vs total_deaths
-- Shows percentage of people got infection

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India'
ORDER BY 1,2;

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

SELECT location, population, MAX(total_cases) AS HighestInfection, ROUND(MAX((total_cases/population)*100),2) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

SELECT location, population, MAX(total_cases) AS HighestInfection, ROUND(MAX((total_cases/population)*100),2) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India'
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

-- Showing Countries with Highest Death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
--AND location like '%India'
GROUP BY location
ORDER BY HighestDeath DESC;

SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL 
--AND location like '%India'
GROUP BY location
ORDER BY HighestDeath DESC;

-- JOIN DEATH AND VACCINATION EXCEL FILES

SELECT *
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vaccination
	ON death.location = vaccination.location
	AND death.date = vaccination.date;

-- LOOKING AT TOTAL POPULATION AND VACCINATION

SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations,
SUM(CAST(vaccination.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vaccination
	ON death.location = vaccination.location
	AND death.date = vaccination.date
WHERE death.continent is NOT NULL
ORDER BY 2,3;

--TEMP TABLE

DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations,
SUM(CAST(vaccination.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as death
JOIN PortfolioProject..CovidVaccinations as vaccination
	ON death.location = vaccination.location
	AND death.date = vaccination.date
WHERE death.continent is NOT NULL
ORDER BY 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--SELECT * FROM CovidPortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT * FROM CovidPortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Total cases vs Total deaths in India
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

-- Total cases vs Population in India
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS CasesPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

-- Maximum infection rates
SELECT location, MAX(total_cases) AS MaxCases, MAX((total_cases/population)*100) AS CasesPercentage
FROM CovidPortfolioProject..CovidDeaths
GROUP BY location
ORDER BY 3 DESC

-- Highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS MaxDeaths
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Highest cases by continent
SELECT continent, MAX(total_cases) AS MaxCases
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100, 2) AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- Total people vs vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccs
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE 1
WITH PercentVac (continent, location, date, population, new_vaccinations, RollingVaccs)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccs
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingVaccs/population)*100 AS PercentageVaccinated
FROM PercentVac 

-- CTE 2
WITH MaxVac (location, population, RollingVaccs)
AS 
(
SELECT dea.location, dea.population, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccs
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT location, population, MAX(RollingVaccs) AS MaxRollingVaccs, MAX((RollingVaccs/population)*100) AS MaxPercentageVaccinated
FROM MaxVac
GROUP BY location, population
ORDER BY MaxPercentageVaccinated DESC

-- Temp table 1
DROP TABLE IF EXISTS #PercentVacc
CREATE TABLE #PercentVacc
(
	Continent nvarchar(250),
	Location nvarchar(250),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingVaccs numeric
)

INSERT INTO #PercentVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccs
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingVaccs/Population)*100 AS PercentVaccinated
FROM #PercentVacc

-- View 1
CREATE VIEW PercentVax AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccs
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * FROM PercentVax

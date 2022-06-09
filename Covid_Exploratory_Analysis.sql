-- Covid19 Data Exploration - Skills used: Joins, Aggregate Functions, Creating Views

-- Data that I am going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_percentage
FROM covid.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate Compared to Population 

SELECT location, population, Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS case_percentage
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY case_percentage DESC;

-- Showing Countries with Highest Death Cunt per Population

SELECT location, Max(total_deaths) AS TotalDeathCount
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing Continents With the Highest Death Count per Population  

SELECT continent, Max(total_deaths) AS TotalDeathCount
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
From coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Creating Views to Store data for later visualizations 

CREATE VIEW TotalPopulationvsVaccinations AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

Create VIEW globalnumber AS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY  1,2;

CREATE VIEW deathcountpercontinent AS
SELECT continent, Max(total_deaths) AS TotalDeathCount
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

CREATE VIEW countrieswithhightesinfectionrate AS
SELECT location, population, Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS case_percentage
FROM covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY case_percentage DESC;


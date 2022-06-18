

SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date,total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2



-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%ia%'
order by 1,2


-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases,(total_cases/population)*100 as InfectedPopulationPercent
FROM PortfolioProject..CovidDeaths
-- where location like '%dia%'
order by 1,2


-- Looking at Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as
  InfectedPopulationPercent
FROM PortfolioProject..CovidDeaths
-- where location like '%dia%'
Group by population, location
order by InfectedPopulationPercent desc


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%dia%'
-- where continent is not null
Group by location
order by TotalDeathCount desc

-- By Continent

--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
---- where location like '%dia%'
---- where continent is not null
--Group by continent
--order by TotalDeathCount desc


--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
---- where location like '%dia%'
--where continent is not null
--Group by location
--order by TotalDeathCount desc


-- Showing Continents with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%dia%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

--SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
--as DeathPercentage
--FROM PortfolioProject..CovidDeaths
---- where location like '%ia%'
--where continent is not null
---- Group by date
--order by 1,2


-- Looking at Total Population vs Vaccinations

SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by de.location order by de.location,
de.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths de
join PortfolioProject..CovidVaccinations vac
     On de.location = vac.location
	 and de.date = vac.date
where de.continent is not null
order by 2,3


-- Use CTE

With PopvsVac(continent, location, date, population,New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by de.location order by de.location,
de.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths de
join PortfolioProject..CovidVaccinations vac
     On de.location = vac.location
	 and de.date = vac.date
where de.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by de.location order by de.location,
de.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths de
join PortfolioProject..CovidVaccinations vac
     On de.location = vac.location
	 and de.date = vac.date
where de.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visulization

CREATE view PercentPopulationVaccinated as
SELECT de.continent, de.location, de.date, de.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by de.location order by de.location,
de.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths de
join PortfolioProject..CovidVaccinations vac
     On de.location = vac.location
	 and de.date = vac.date
where de.continent is not null
-- order by 2,3

SELECT *
FROM PercentPopulationVaccinated


  



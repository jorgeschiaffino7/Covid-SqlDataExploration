SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2
-- ORDER BY 1,2 se agruapara en forma ascendente la columna 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country - probalidad de morir si contraes covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%Argentina%'
-- tener en cuenta las comillas simples - single quotes
ORDER BY 1,2
------------------------------------------------------------------
--------------------------------------------------------------


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%Argentina%'
-- tener en cuenta las comillas simples - single quotes
ORDER BY 1,2

------------------

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount ,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- where location like '%Argentina%'
-- tener en cuenta las comillas simples - single quotes
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
---------------------------------------------------------------


-- Showing Countries with Highest Death Count per Population
-- cast = cambia un valor a otro

SELECT location, MAX( cast( Total_deaths as int )) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%Argentina%'
where continent is null
--- para que me devuelva los pasies, tengo que agregar, where continent is not null
-- tener en cuenta las comillas simples - single quotes
GROUP BY location
ORDER BY TotalDeathCount DESC

-----------------------------------------------------

-- LET´S BREAK THING DOWN BY CONTINENT

SELECT continent, MAX( cast( Total_deaths as int )) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%Argentina%'
where continent is not null
--- para que me devuelva los pasies, tengo que agregar, where continent is not null
-- tener en cuenta las comillas simples - single quotes
GROUP BY continent
ORDER BY TotalDeathCount DESC

------------------------------------------------------------

-- Showing Continents with Highest Death Count per Population

SELECT continent, MAX( cast( Total_deaths as int )) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%Argentina%'
where continent is not null
--- para que me devuelva los pasies, tengo que agregar, where continent is not null
-- tener en cuenta las comillas simples - single quotes
GROUP BY continent
ORDER BY TotalDeathCount DESC

------------------------------------------
-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--where continent like '%Argentina%'
-- tener en cuenta las comillas simples - single quotes
ORDER BY 1,2

---------------------------------------------------------------------------------------------------

-- looking at Total Population vs Vaccinations

SELECT *
FROM PortfolioProject..CovidDeaths dea -- ocupamos alias = dea
Join PortfolioProject..CovidVaccinations$ vac -- ocupamos alias = vac
	On dea.location = vac.location
	and dea.date = vac.date
	------------------------------------------------------------------------------------------------------

	--- vaccinations per day ---
	--- USE CTE
	-- A CTE (common table expression, the part that is wrapped in the "with") is essentially a 1-time view
	With PopvsVac (Continent, location,date,population,new_vaccinations,RollingPeopleVaccinated) as 
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations))
	-- bigint = data type in SQL Server is the 64-bit representation of an integer. It takes up 8 bytes of storage.
	-- con los alias indicamos de que tabla viene los datos
	OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea -- ocupamos alias = dea
Join PortfolioProject..CovidVaccinations$ vac -- ocupamos alias = vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--ORDER BY 2,3
	)

	select*, (RollingPeopleVaccinated/population)*100
	from PopvsVac
	------------------------------------------------------------------------------------------------------------------------

	--- TEMP TABLE

		Create table #PercentPopulationVaccinated
		(
		Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		Population numeric,
		New_vaccionations numeric,
		RollingPeopleVaccinated numeric
		
		)


	insert into #PercentPopulationVaccinated
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations))
	-- bigint = data type in SQL Server is the 64-bit representation of an integer. It takes up 8 bytes of storage.
	-- con los alias indicamos de que tabla viene los datos
	OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea -- ocupamos alias = dea
Join PortfolioProject..CovidVaccinations$ vac -- ocupamos alias = vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--ORDER BY 2,3

		select*, (RollingPeopleVaccinated/population)*100
	from #PercentPopulationVaccinated

	-----------------------------------------------------------------------------------

	-- Creating View to store data for later visualizations

	Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations))
	-- bigint = data type in SQL Server is the 64-bit representation of an integer. It takes up 8 bytes of storage.
	-- con los alias indicamos de que tabla viene los datos
OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea -- ocupamos alias = dea
Join PortfolioProject..CovidVaccinations$ vac -- ocupamos alias = vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--ORDER BY 2,3
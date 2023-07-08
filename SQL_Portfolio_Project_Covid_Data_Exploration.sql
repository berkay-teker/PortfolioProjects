Select *
From CovidDeaths
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
From CovidDeaths
Where location like '%turkey%'
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Infected by Covid
Select location, date, population, total_cases, (total_cases/population) * 100 as InfectionPercentage
From CovidDeaths
Where location like '%turkey%'
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as MaxInfectionRate
From CovidDeaths
Where continent is not null
Group By location, population
Order By 4 Desc


--Showing countries with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount 
From CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population


Select continent, MAX(total_deaths) as TotalDeathCount 
From CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc

Select location, MAX(total_deaths) as TotalDeathCount 
From CovidDeaths
Where continent is null
Group By location
Order By TotalDeathCount desc


-- Global Numbers
--Day by Day Cases, Death and Percentage
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/nullif(SUM(new_cases),0) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group By date
Order By 3 desc

--Total Case, Death and Percentage
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/nullif(SUM(new_cases),0) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group By date
Order By 3 desc


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)* 100
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations,  rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)* 100
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (rollingpeoplevaccinated/population) * 100 as PercentageofPopVaccinated
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population float,
new_vaccinations float,
rollingpeoplevaccinated float
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null


Select *, (rollingpeoplevaccinated/population) * 100 as PercentageofPopVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visulatizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated
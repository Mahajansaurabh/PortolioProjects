select * from dbo.['covid-death$']  order by 3,4
select * from dbo.['covid-vaccinations$'] order by 3,4

select * from dbo.['covid-vaccinations$'] 
where continent is not null
order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population 
from dbo.['covid-death$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.['covid-death$']
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
-- Show what percentage of population got Covid

select Location, date,Population, total_cases, (total_deaths/population)*100 as PercentPOpulationInfected
from dbo.['covid-death$']
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from dbo.['covid-death$']
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.['covid-death$']
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Lets Break things Down By Continent
-- Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.['covid-death$']
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

select  date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.['covid-death$']
where continent is not null
Group By date
order by 1,2

select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.['covid-death$']
where continent is not null
Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date ,dea.population , vac.new_vaccinations,
  SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
from dbo.['covid-death$']  dea
Join dbo.['covid-vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location,Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date ,dea.population , vac.new_vaccinations,
  SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
from dbo.['covid-death$']  dea
Join dbo.['covid-vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date ,dea.population , vac.new_vaccinations,
  SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
from dbo.['covid-death$']  dea
Join dbo.['covid-vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date ,dea.population , vac.new_vaccinations,
  SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
from dbo.['covid-death$']  dea
Join dbo.['covid-vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated

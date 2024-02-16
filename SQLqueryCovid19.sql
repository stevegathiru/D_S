select * 
From PortfolioCovid19..CovidDeaths
order by 3, 4

--select * 
--From PortfolioCovid19..CovidVaccinations
--order by 3, 4

--Selecting Data we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioCovid19..CovidDeaths
order by 1,2

Alter Table PortfolioCovid19..CovidDeaths
Alter COLUMN total_deaths FLOAT
Alter Table PortfolioCovid19..CovidDeaths
Alter COLUMN total_cases FLOAT

-- Looking at Total Cases Vs Total Deaths
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage  
From PortfolioCovid19..CovidDeaths
Where location like 'Kenya'
where continent is not null
order by 1,2

-- Looking at the total cases vs Population
Select location, date, total_cases, population,(total_cases/population)*100 as CasePercentage  
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
order by 1,2

-- Looking at countries with highest Infection Rate compared to population.
Select location, population, MAX(total_cases),MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by population, location
order by PercentPopulationInfected desc

--Showing countries with highest Death Count per Population
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Breaking things down by continent

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
--Where location is not 'World','High income', 'Upper middle income', 'Lower middle income', 'European union', 'Low income'
Where continent is null
Group by location
order by TotalDeathCount desc


-- Showing the continents with the highest death counts per population
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage  
From PortfolioCovid19..CovidDeaths
--Where location like 'Kenya'
where continent is not null
order by 1,2

--- New Cases worldwide

Select date, SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths
From PortfolioCovid19..CovidDeaths
where new_cases != 0
where new_deaths != 0
where continent is not null
Group By date
order By 1,2

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)* 100 as DeathPercentage
From PortfolioCovid19..CovidDeaths
Where continent is not null
Group By date
order By DeathPercentage desc

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)* 100 as DeathPercentage
From PortfolioCovid19..CovidDeaths
where continent is not null
--Group By date
order By DeathPercentage desc

Select *
From PortfolioCovid19..CovidDeaths dea
Join PortfolioCovid19..CovidVaccinations vac
    on dea.location = vac.location and dea.date = vac.date

--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as CumulativeVaccinations
, (CumulativeVaccinations/population)*100
From PortfolioCovid19..CovidDeaths dea
Join PortfolioCovid19..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent,location, date, population,new_vaccinations, CumulativeVaccinations)

as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as CumulativeVaccinations
--(CumulativeVaccinations/population)*100
From PortfolioCovid19..CovidDeaths dea
Join PortfolioCovid19..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (CumulativeVaccinations/population)*100 as 
From PopvsVac


-- Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated

(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccinations numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as CumulativeVaccinations
--(CumulativeVaccinations/population)*100
From PortfolioCovid19..CovidDeaths dea
Join PortfolioCovid19..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null

Select*, (CumulativeVaccinations/population)*100 
From #PercentagePopulationVaccinated

--Creating View to store Data for later visualizations

Drop view if exists PercentagePopulationVaccinated
Create View PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as CumulativeVaccinations
--(CumulativeVaccinations/population)*100
From PortfolioCovid19..CovidDeaths dea
Join PortfolioCovid19..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
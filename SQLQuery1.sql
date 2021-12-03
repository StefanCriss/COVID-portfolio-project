

--Select Data that is going to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 
Location,
date;

--Percentage of deaths in Romania

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location='Romania'
order by 
total_deaths
desc;


--Total Cases vs Population 
--Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopInfected
from PortfolioProject..CovidDeaths
where location='Romania'
order by 
1,2
desc;


--Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by 
PercentPopInfected
desc;

--Countries with the highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc;


--Continents with the highest Death Count per Population


Select continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;


--Global Numbers

Select SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, SUM (cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group By date
Order by NewDeaths 
desc


--Total population vs. total vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(Convert(int, vacc.new_vaccinations)) OVER ( Partition by deaths.Location Order by deaths.location,
deaths.date) as TotalVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
On deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null
Order by 2,3 asc


-- using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(Convert(int, vacc.new_vaccinations)) OVER ( Partition by deaths.Location Order by deaths.location,
deaths.date) as TotalVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
On deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null)

Select *, (TotalVaccinations/Population)*100 as PercentOfTotalVacc
From PopvsVac


--using Temp Table


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
continent nvarchar(255),
location nvarchar(255),
date datetime,  
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(Convert(int, vacc.new_vaccinations)) OVER ( Partition by deaths.Location Order by deaths.location,
deaths.date) as TotalVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
On deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null

Select *, (TotalVaccinations/Population)*100 as PercentOfTotalVacc
From #PercentPopulationVaccinated 

--Create Views to store data for later visualizations

--View for Population vs Vaccinations

Create View PopVerVac as
With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(Convert(int, vacc.new_vaccinations)) OVER ( Partition by deaths.Location Order by deaths.location,
deaths.date) as TotalVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
On deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null)

Select *, (TotalVaccinations/Population)*100 as PercentOfTotalVacc
From PopvsVac


--View for Percent of the population Vaccinated

 Create View PercentPopulationVacinated 
 as
 Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(Convert(int, vacc.new_vaccinations)) OVER ( Partition by deaths.Location Order by deaths.location,
deaths.date) as TotalVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
On deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null





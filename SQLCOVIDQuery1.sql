
Select *
from PortfolioProject..COVIDDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject.dbo.COVIDVaccinations
--order by 3,4

--Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..COVIDDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total deaths
--Roughly shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Percentage
From PortfolioProject..COVIDDeaths
Where location like '%states%' and total_deaths is not null
order by 1,2

--Looking at the Total Cases vs Population
--Roughly shows what percentage of population contracted covid
Select Location, date, population, total_cases, (total_cases/population)*100 as COVID_Percentage
From PortfolioProject..COVIDDeaths
--Where location like '%states%' and total_cases is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..COVIDDeaths
--Where location like '%states%' and total_cases is not null
group by location, population
order by PercentPopulationInfected desc

--Looking at countries with the highest death count compared to population
Select Location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentPopulationDeaths
From PortfolioProject..COVIDDeaths
--Where location like '%states%' and total_cases is not null
where continent is not null
group by location, population
order by PercentPopulationDeaths desc

--Looking at countries with the highest death count
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..COVIDDeaths
where continent is not null
--Where location like '%states%' and total_cases is not null
group by location
order by TotalDeathCount desc


-- LET'S GROUP BY CONTINENT NOW
--Correct Numbers based on those continents in the location fields that are null
--Showing the continents with the highest death count
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..COVIDDeaths
where continent is null
--Where location like '%states%' and total_cases is not null
group by location
order by TotalDeathCount desc

--Not Correct, but based on continent field that is not null
--Showing the continents with the highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..COVIDDeaths
where continent is not null
--Where location like '%states%' and total_cases is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
--Month by Month Global Death Percentage
Select year(date) as Year, month(date) as Month, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deaths_Percentage
From PortfolioProject..COVIDDeaths
--Where location like '%states%' and total_deaths is not null
Where continent is not null
Group by month(date), year(date)
order by 1,2

--Global Death Percentage
Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deaths_Percentage
From PortfolioProject..COVIDDeaths
--Where location like '%states%' and total_deaths is not null
Where continent is not null
--Group by month(date), year(date)
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RunningVacTotal
--,(RunningVacTotal/population)*100 as PercentageVacPop
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE Common Table Expression (CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RunningVacTotal)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RunningVacTotal
--,(RunningVacTotal/population)*100 as PercentageVacPop
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RunningVacTotal/Population)*100 as PercentageVacPop
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningVacTotal numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RunningVacTotal
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RunningVacTotal/Population)*100 as PercentageVacPop
From #PercentPopulationVaccinated
order by 2,3


--Create View to store data for later visualziations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RunningVacTotal
--,(RunningVacTotal/population)*100 as PercentageVacPop
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RunningVacTotal
,((SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date))/population)*100 as PercentageVacPop
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

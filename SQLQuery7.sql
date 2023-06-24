--Data Exploration of Coronavirus by Bams


Select *
From portfolioProject..CovidDeaths
Where Continent is not null
order by 3,4


--Now I'll Select the Data/Columns to be used in this query
Select Location, date , total_cases,new_cases,total_deaths,Population
From portfolioProject..CovidDeaths
Where Continent is not null
order by 1,2

--What is the percentage of people who had covid and die by it 
--I'm checking the Total Cases vs Total Deaths
Select Location, date , total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_Of_Deaths ,Population
From portfolioProject..CovidDeaths
Where Continent is not null
order by 1,2

--What is the deaths percentage of ppeople who had Covid and die
--Show th likehood of dying if you contract covid in Nigeria 
Select Location, date , total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_Of_Deaths ,Population
From portfolioProject..CovidDeaths
Where location like '%Nigeria'
order by 1,2

--Lookin as Total Cases vs Population
--This show whar percentage got covid
--Thhs show the Contagious rate in Nigeria
Select Location, date , Population,total_cases,(total_cases/Population)*100 as ContagiousPercent 
From portfolioProject..CovidDeaths
Where  Continent is not null and location like '%Nigeria'  
order by 1,2

--Looking at the Countries with Highest Infection Rate Compared to Population 
Select Location,continent, Population,max(total_cases)As HighestIfectioncount,max((total_cases/Population))*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
Where Continent is not null
Group by Location,continent,Population
order by PercentPopulationInfected desc

--Looking at Nigeria  with Highest Infection Rate Compared to Population 
Select Location,continent, Population,max(total_cases)As HighestIfectioncount,max((total_cases/Population))*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
Where location like '%Nigeria'
Group by continent,Population
order by PercentPopulationInfected desc

--This Show the Countries Higest DeathCout Per Population
Select Location,continent,Max(cast(Total_deaths as int)) as TotalDeathcount
From portfolioProject..CovidDeaths
Where Continent is not null
Group by Location,continent
order by TotalDeathcount desc

--LET'S Break Things Doen By Continent 

--Showing th  continent with Higest  death count per population
Select Location ,Max(cast(Total_deaths as int)) as TotalDeathcount
From portfolioProject..CovidDeaths
Where continent is  null
Group by Location
order by TotalDeathcount desc



--Showing th  continent with Higest  death count per population
Select Continent,Max(cast(Total_deaths as int)) as TotalDeathcount
From portfolioProject..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathcount desc

--GLOBAl NUMBERS
Select Sum(new_cases) as TotalCases,Sum(cast(new_deaths as int))as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases) as DeathPercentage
From portfolioProject..CovidDeaths
Where Continent is not null 
order by 1,2

--This show the Covid Vanccinations Table
Select *
from PortfolioProject..CovidVaccinations

--I'll Join the COVID DEATHS TABLE and COVID VANCCINATIONS TABLE
Select * 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
order by 1,2

--Looking at Total Popuation Vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3
	
--This is for Rolling Count 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.Location Order by dea.Location,dea.date) as RollingTotalVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3

--Looking at the Total Population vs vaccinations using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
as 
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.Location Order by dea.Location,dea.date) as RollingTotalVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3
)
Select * ,(RollingTotalVaccinations/Population)*100 as CumulativePercentage
From PopvsVac


--Looking at the Total Population vs vaccinations using Temp Table
Drop Table if exists #PercentPopulatonVaccinated
Create Table #PercentPopulatonVaccinated
(
Continent varchar(225), 
Location varchar(225), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingTotalVaccinations numeric
)


Insert into #PercentPopulatonVaccinated

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.Location Order by dea.Location,dea.date) as RollingTotalVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3

Select * ,(RollingTotalVaccinations/Population)*100 as CumulativePercentage
From #PercentPopulatonVaccinated

--Now creating Views to store data for visualization

Create View PercentPopulatonVaccinated as
s 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.Location Order by dea.Location,dea.date) as RollingTotalVaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null


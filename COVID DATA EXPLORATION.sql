Select *
From PortfolioProject..[covid deaths]
WHERE continent is not null
order by 3,4

Select*
From PortfolioProject..[covid deaths]
order by 3,4

Select location , date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[covid deaths]
order by 1,2

-- shows likelihood of dying if you contract covid in our country
Select location, date, total_cases,  total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..[covid deaths]
Where location like '%india%'
and continent is not null
order by 1,2


-- shows what percentage of population got covid
Select location, date, total_cases, population,(total_cases/population)* 100 as PercentPopulationInfected
From [PortfolioProject]..[covid deaths]
Where location like '%india%'
order by 1,2


--looking at Countries with Highest Infection Rate compared to Population
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)* 100 as PercentPopulationInfected
From PortfolioProject..[covid deaths]
Group by location ,population
order by PercentPopulationInfected desc



-- showing Countires with Highest Death count per Population
Select location, MAX(cast( total_deaths as int)) as TotalDeathCount
From PortfolioProject..[covid deaths]
WHERE continent is not null
Group by location 
order by TotalDeathCount desc

--GLOBALNUMBERS
Select  SUM( new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as  DeathPercentage
From [PortfolioProject]..[covid deaths]
WHERE continent is not null
order by 1,2


-- Looking at Total Poppulation vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER( Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
From [PortfolioProject]..[covid deaths] dea
Join [PortfolioProject]..[covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3




--USE CTE

with PopvsVac(Continent , location ,date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER( Partition by dea.location Order by dea.location ,
 dea.date) as RollingPeopleVaccinated
From [PortfolioProject]..[covid deaths] dea
Join [PortfolioProject]..[covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
Select* ,(RollingPeopleVaccinated/population)*100 as Percentage
From PopvsVac



--temp Table

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- creating view

 Create View PercentPopulationvaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER( Partition by dea.location Order by dea.location ,
 dea.date) as RollingPeopleVaccinated
From [PortfolioProject]..[covid deaths] dea
Join [PortfolioProject]..[covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null




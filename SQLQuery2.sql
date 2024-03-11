select *
from coviddeaths 

select location, date, total_cases, total_deaths, population
from Coviddeaths
order by 1,2 

-- Looking at total cases v/s total deaths 

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from Coviddeaths
where total_cases is not null


-- Looking at total cases v/s population 
-- showing what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from Coviddeaths
where location like '%states%'
order by 1,2 

-- Looking at countries with highest infection rate compared to population 
Select location, percentpopulationinfected
From
(
select location, population, Max(total_cases) as highestinfectioncount,  Max(total_cases/population)*100 as percentpopulationinfected
from Coviddeath
--where location like '%states%'
group by population, location
)  as innerTable
where location like 'S%'
order by  percentpopulationinfected desc

--Showing countries with highest death count per population 
select location, Max(total_deaths) as Totaldeathcount
from Coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by  Totaldeathcount desc

--Lets break things down by continent 
-- Showing continents with highest death count per poputation

select continent, Max(total_deaths) as Totaldeathcount
from Coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by  Totaldeathcount desc

-- Global numbers 
select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as deathpercentage
from Coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2 

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(float, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as Rollingpeoplevaccinated
From Coviddeaths dea
join Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 desc

-- Use CTE

with popvsvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Coviddeaths dea
join Covidvaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select* , (Rollingpeoplevaccinated/population)*100
from PopvsVac


--Temp table
Create table #percentpopulationvaccination
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #percentpopulationvaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as Rollingpeoplevaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Select* , (Rollingpeoplevaccinated/population)*100
from PopvsVac 

---Creating view to store data for later visulizations 

Create view Percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float.vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as Rollingpeoplevaccinated
from Coviddeaths dea
join Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
# Covid-19 Data Explorations

select * from 
portfolioproject.coviddeaths
order by 3,4;
 
 -- Convert both files date format into YY-MM-DD
 
update portfolioproject.coviddeaths
set date = str_to_date(date,'%d-%m-%Y');

update portfolioproject.covidvaccinations
set date = str_to_date(date,'%d-%m-%Y');


-- select * from 
-- portfolioproject.covidvaccinations
-- order by 3,4

# Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioproject.CovidDeaths 
where continent !=""
order by 1,2;

# Total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths
where location like '%states%' 
and continent is not null
order by 1,2;

# Total Cases vs Population
# Shows what percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject.coviddeaths
where location = 'india'
order by 1,2;

# Countries with Highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject.covidDeaths
group by location, Population
order by PercentPopulationInfected desc;

# Countries with Highest Death count Per Population

Select location, max(cast(total_deaths as unsigned)) as TotalDeathCount, Population
from portfolioproject.coviddeaths
-- where location = 'India'
where continent !=""
group by location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with Highest Death count Per Population

Select Continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
from portfolioproject.coviddeaths
where continent !=""
group by Continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as unsigned)) as total_deaths, SUM(CAST(new_deaths as unsigned))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths
where continent !=""
order by 1,2;

-- Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one Covid vaccine

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from portfolioproject.coviddeaths as cd
Join portfolioproject.covidvaccinations as cv
    on cd.location = cv.location 
    and cd.date = cv.date
where cd.continent != ""
order by 2,3;

-- looking at Total vaccination (Rolling Total)

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(cv.new_vaccinations, unsigned)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from portfolioproject.coviddeaths as cd
Join portfolioproject.covidvaccinations as cv
    on cd.location = cv.location 
    and cd.date = cv.date
where cd.continent != ""
order by 2,3;

-- looking at Total Population vs Vaccinations (Rolling Total) with CTE

With PopVsVac(Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(cv.new_vaccinations, unsigned)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from portfolioproject.coviddeaths as cd
Join portfolioproject.covidvaccinations as cv
    on cd.location = cv.location 
    and cd.date = cv.date
where cd.continent != ""
)
select *, (RollingPeopleVaccinated/Population) * 100
from PopVsVac;

-- Creating view to store data for later Visualisations

Create View PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(convert(cv.new_vaccinations, unsigned)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from portfolioproject.coviddeaths as cd
Join portfolioproject.covidvaccinations as cv
    on cd.location = cv.location 
    and cd.date = cv.date
where cd.continent != "";

select * 
from PercentPopulationVaccinated;
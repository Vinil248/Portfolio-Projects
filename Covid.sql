--Preparing data for the Proejct 

Select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Projects]..['Covid death']
where continent is not null
order by 1,2

-- Total cases vs Total death , in UK

Select location,date,total_cases,total_deaths,(CONVERT(decimal(18,2),total_deaths)/CONVERT(decimal(18,2),total_cases))*100 as deathpercentage
from [Portfolio Projects]..['Covid death']
where location like '%United Kingdom%'
order by 1,2

-- Total cases vs Total Population(in percentage ) in UK
Select location,date,total_cases,population,(total_cases/population)*100 as population_percent
from [Portfolio Projects]..['Covid death']
where location like '%United Kingdom%'
order by 1,2

-- Countries with highest infection rate 
Select location,MAX(cast(total_cases as int)) as Infection_Count
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location
Order by Infection_Count desc

-- Countries with highest infection rate per population
Select location,population,MAX(cast(total_cases as int)) as Highestinfectioncount,MAX(cast(total_cases as int))/population*100 as population_infected_Percent
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location,population
Order by Highestinfectioncount desc

--- Countries with highest death count 
Select location,MAX(cast(total_deaths as int)) as Death_count
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location
Order by Death_count desc

--- Countries with highest death count per population
Select location,population,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX(cast(total_deaths as int))/population*100 as Highest_deathcount_Percent
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location,population
Order by Highestdeathcount desc

--- Continent with highest death count 
Select continent,MAX(cast(total_deaths as int)) as Total_deathcount
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by continent
Order by Total_deathcount desc

--- Continent with highest death count per population
Select continent,population,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX(cast(total_deaths as int))/population*100 as Highest_deathcount_Percent
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by continent,population
Order by Highestdeathcount desc

-- joining vaccination table with death 

select*
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date

-- Total population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	
	order by 2,3

	-- Total population vs Vaccinations ,(rolling count)

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)	as People_vaccinated_rolling
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	
	order by 2,3


	--- use CTE & Temp table to use mathematical functions on newly created columns 

	With PopvsVac(continent,location,date,population,new_vaccination,People_vaccinated_rolling)
	as
	(
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)	as People_vaccinated_rolling
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	
)
select*, (People_vaccinated_rolling/population)*100 as percentage_peoplevaccinated
from PopvsVac


--- temp table

Create table Populationvaccinatedpercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
People_vaccinated_rolling numeric
)
Insert into Populationvaccinatedpercentage
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)	as People_vaccinated_rolling
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	

	select*, (People_vaccinated_rolling/population)*100 as percentage_peoplevaccinated
from Populationvaccinatedpercentage

---Create view to store data for visualisations

create view highestinfection_rate as
Select location,MAX(cast(total_cases as int)) as Infection_Count
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location

create view highestinfectionrate_population as
Select location,population,MAX(cast(total_cases as int)) as Highestinfectioncount,MAX(cast(total_cases as int))/population*100 as population_infected_Percent
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location,population

Create view highestdeath_count as
Select location,MAX(cast(total_deaths as int)) as Death_count
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location

Create view highestdeathcount_population as
Select location,population,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX(cast(total_deaths as int))/population*100 as Highest_deathcount_Percent
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by location,population

Create view Continent_highestdeathcount as
Select continent,MAX(cast(total_deaths as int)) as Total_deathcount
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by continent

Create View Continent_highestdeathcount_population as
Select continent,population,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX(cast(total_deaths as int))/population*100 as Highest_deathcount_Percent
from [Portfolio Projects]..['Covid death']
where continent is not null
Group by continent,population

Create View Pop_Vac as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	

	Create View Pop_Vac_Rollingcount as
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)	as People_vaccinated_rolling
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	

	Create View CTE_Aggregate as
	With PopvsVac(continent,location,date,population,new_vaccination,People_vaccinated_rolling)
	as
	(
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)	as People_vaccinated_rolling
from [Portfolio Projects]..['Covid death']dea
join [Portfolio Projects]..['Covid Vaccination']vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null	
)
select*, (People_vaccinated_rolling/population)*100 as percentage_peoplevaccinated
from PopvsVac
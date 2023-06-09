--select *

--from
--CovidDeaths$
--order by 3,4


--Select data that we will be working on


select Location, date, total_cases , new_cases , total_deaths , population

from CovidDeaths$
order by 1 ,2 

--Looking at total cases vs total deaths 

select 
Location, 
date , 
total_cases , 
total_deaths ,
round((convert(float,total_deaths)/convert(float,total_cases)),5)*100 as deathpercent

from CovidDeaths$
where location = 'India'
order by 1 ,2 desc

-- Total cases vs population

select 
Location, 
date , 
total_cases , 
population ,
round((convert(float,total_cases)/convert(float,population)),5)*100 as covidpercent

from CovidDeaths$
where location = 'India'
order by 1 ,2 desc

-- countries with highest infection rate compared to population
select 
Location,
population,
max(total_cases) as Highestinfcount , 
Max(convert(float,total_cases)/convert(float,population))*100 as percrntnfectionrate

from CovidDeaths$
group by location,population
order by percrntnfectionrate desc

--countries with highest death count per population
select 
Location,
population,
max(convert(float,total_deaths)) as totaldeathcount 

from CovidDeaths$
where continent is not null
group by location,population
order by totaldeathcount desc

-- according to continents
select 
continent,

max(convert(float,total_deaths)) as totaldeathcount 

from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

--get global numbers
select 
continent,
max(convert(float,total_deaths)) as totaldeathcount 

from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc



--getting death percentage
select 

sum(convert(float,new_deaths)) as total_deaths ,
sum(new_cases) as total_cases,
sum(convert(float,new_deaths)/sum(new_cases))*100 as deathpercentage


from CovidDeaths$
where continent is not null
--group by date,total_cases
order by 1,2


--totalvacc vs total population
select 
d.location,
d.continent,
d.population,
d.date,
v.new_vaccinations,
sum (convert(float,new_vaccinations)) over (partition by d.location order by d.location, d.date) as rollingpeoplevacc
from CovidDeaths$ d
join covidVaccinations$  v
on
d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1	desc

--Use CTE

with popvsvacc( location,continent,population,date,new_vaccinations,rollingpeoplevacc)
as
(
select 
d.location,
d.continent,
d.population,
d.date,
v.new_vaccinations,
sum (convert(float,new_vaccinations)) over (partition by d.location order by d.location, d.date) as rollingpeoplevacc
from CovidDeaths$ d
join covidVaccinations$  v
on
d.location=v.location
and d.date=v.date
where d.continent is not null

)

select *, (convert(float,rollingpeoplevacc)/convert(float,population))*100
from popvsvacc

--temptable
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated

( continent nvarchar (255),
location nvarchar (255),
population numeric,
date datetime,
new_vaccinations numeric,
rollingpeoplevacc numeric
)

Insert Into #percentpopulationvaccinated
select 
d.location,
d.continent,
d.population,
d.date,
v.new_vaccinations,
sum (convert(float,new_vaccinations)) over (partition by d.location order by d.location, d.date) as rollingpeoplevacc
from CovidDeaths$ d
join covidVaccinations$  v
on
d.location=v.location
and d.date=v.date
where d.continent is not null

select *, (convert(float,rollingpeoplevacc)/convert(float,population))*100
from  #percentpopulationvaccinated


--create views for visualization

create view percentpopulationvaccinat
as
select 
d.location,
d.continent,
d.population,
d.date,
v.new_vaccinations,
sum (convert(float,new_vaccinations)) over (partition by d.location order by d.location, d.date) as rollingpeoplevacc
from CovidDeaths$ d
join covidVaccinations$  v
on
d.location=v.location
and d.date=v.date
where d.continent is not null

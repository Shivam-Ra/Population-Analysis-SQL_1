Select * From In_population..Pop_indicators;
Select * From In_population..Populations;

-- Removing Null values From Pop_indicators table

Delete from Pop_indicators
where district is null;

-- Deleting incorrect Record in table Pop_indicators

Delete from Pop_indicators
where district = 'District';

-- Number of rows in our Dataset

Select count(*) From Pop_indicators;
Select count(*) From Populations;

-- Dataset For Haryana and Delhi only

Select * from Pop_indicators 
Where State in ('Haryana','Delhi');

-- Total Population of the Country 

Select Sum(Population) as Total_Population 
From Populations;


-- Average growth of the Population for each state 

Select State, round(Avg(growth)*100,2) as Avg_growth
from Pop_indicators
group by State
order by avg_growth DESC;

-- Average Sex Ratio by Sate

Select State, Round(Avg(sex_ratio),0) as Avg_SexRatio
from Pop_indicators
group by State
order by Avg_SexRatio desc;

-- States Having Average Literacy rate morethan 90

Select state, round(avg(literacy),0) Avg_literacy
From Pop_indicators
group by State
Having  round(avg(literacy),0) > 90
Order by Avg_literacy Desc;

-- Top 3 State showing Average growth

Select Top 3 State, Avg(Growth)*100 as Avg_growth 
From Pop_indicators
group by State
order by Avg_growth desc;

-- Bottom 3 State showing Average sex ration

Select Top 3 State, Avg(sex_ratio) as Avg_SexRatio
From Pop_indicators
group by State
order by Avg_SexRatio ASC;


-- Top 3 and Bottom 3 States in Literacy rate 

Select * from
(Select top 3 State, round(avg(literacy),0) Avg_literacy
From Pop_indicators
group by State
order by Avg_literacy desc) a

union

Select * from (Select top 3 State, round(avg(literacy),0) Avg_literacy
From Pop_indicators
group by State
order by Avg_literacy ASC) b
order by Avg_literacy desc;


-- Give the states for Name starting from a and b

Select distinct state From Pop_indicators
where lower(State) like 'a%' or lower(state) like 'b%';

-- Give the data for states starting from a and ending with m

Select distinct state from Pop_indicators
where lower(state) like 'a%' and lower(state) like '%m';

-- Give Total numeber of Male and female in each State

Select a.state, 
sum(a.population) as population,
sum(a.female) as female, 
sum(a.male) as Male
From (
Select a.state, b.population, round((b.population)/(a.sex_ratio+1000)*a.sex_ratio,0) as Female,
Round((b.population)/(a.sex_ratio+1000)*1000,0) as Male 
from Pop_indicators a
join Populations b
on a.district = b.District
and a.State = b.State
) a
Group By a.State;

-- Showing Total Literate as well as Total illiterate Population by District

select 
a.district,
a.state,
b.Population, 
Round((b.population)*(a.literacy/100),0) as Total_literate,
round((b.population)-b.population*(a.literacy/100),0) as Total_Illiterate
From Pop_indicators a
Join Populations b
on a.district = b.district
and a.State = b.State;


-- Provide the population of each State in Previous sensus as well as current sensus

with CTE as (
	Select a.State,
	b.Population as Current_population,
	Round(b.Population/(1+a.Growth),0) as Previous_population
	From Pop_indicators a
	Join Populations b
	on a.District = b.District
	and a.State = b.State
	)
Select State, Sum(current_population) as C_Population,Sum(Previous_population) as P_Population
From CTE
Group By State;

-- Give total population for Previous Sensus and Current Sensus of the Country.

Select Sum (b.Population)as Current_population,
sum(Round(b.Population/(1+a.Growth),0)) as Previous_population
From Pop_indicators a
Join Populations b
on a.District = b.District
and a.State = b.State;

/** While validating the total populaton of Populations table with joined table(Populations and Pop_indicators).
we found some discrepancy, after checking we noticed 1 district name is mismatching because of spelling mistake.
So to rectify above mistake we had to rename 1 district. **/

-- we found the mismatched record using Except operator
select distinct district, state from Populations
Except
select distinct district, state from Pop_indicators

--Updated the record "Dadra & Nagar Haveli" to "Dadra and Nagar Haveli"
Update Populations
Set District = 'Dadra and Nagar Haveli',
State = 'Dadra and Nagar Haveli'
Where District = 'Dadra & Nagar Haveli';


-- Show top 3 district From each state which have Highest Literacy rate.

With CTE1 as (
Select District, State, Literacy, DENSE_RANK() Over (Partition by State order by Literacy desc) as DRank
From Pop_indicators
)
Select * FROM CTE1 Where DRank <=3;

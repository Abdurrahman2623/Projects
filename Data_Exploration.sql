-- Data exploration

select *
from layoffs_staging2;

-- companies that completely dissolved 
select *
from layoffs_staging2
where percentage_laid_off = 1
;

-- Countries with the most most dissolved companies
select industry, count(company)
from layoffs_staging2
where percentage_laid_off = 1
group by industry
order by count(company)
;

-- how the funds affect layyoffs
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions Desc 
;

-- Total layoffs by country 
Select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc
;
-- country could be replaced with industry and company to know the company and industries that suffered the most layoffs 

-- the year span 
select min(`date`), max(`date`)
from layoffs_staging2
;

-- layoffs by date
Select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by year(`date`)
;

-- layoffs by stage
Select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc
;

-- layyoffs by months
select substring(`date`,1,7) as `month` , sum(total_laid_off) as lay_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
;

-- rolling total by the months and year
with rolling_total as 
(
select substring(`date`,1,7) as `month` , sum(total_laid_off) as lay_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, lay_off, sum(lay_off) over(order by `month`) as rolling_total
from rolling_total;

-- Create rank and rank the compenies based in the otal layoffs 
with Company_year (company, years, total_laid_off) as 
(
Select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
),
company_year_rank as 
(
select *, dense_rank() over (partition by years order by total_laid_off desc) as `Rank`
from Company_year
where years is not null
)
select*
from company_year_rank
where `rank` <= 5
;
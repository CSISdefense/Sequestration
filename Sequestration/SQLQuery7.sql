select fiscal_year
,sum(obligatedamount) as obligatedamount
from contract.fpds
group by fiscal_year
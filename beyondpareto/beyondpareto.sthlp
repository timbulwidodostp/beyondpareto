{smcl}
{* *! version 1.1 20feb2024}{...}
{viewerjumpto "Title" "beyondpareto##title"}{...}
{viewerjumpto "Table of contents" "beyondpareto##contents"}{...}
{viewerjumpto "Syntax" "beyondpareto##syntax"}{...}
{viewerjumpto "Description" "beyondpareto##description"}{...}
{viewerjumpto "Options" "beyondpareto##options"}{...}
{viewerjumpto "Examples" "beyondpareto##examples"}{...}
{viewerjumpto "Stored results" "beyondpareto##results"}{...}
{viewerjumpto "References" "beyondpareto##references"}{...}
{viewerjumpto "Authors" "beyondpareto##authors"}{...}
{viewerjumpto "Also see" "beyondpareto##see"}{...}
{cmd:help beyondpareto}{right: ({browse "https://doi.org/10.1177/1536867X251322969":SJ25-1: st0770})}
{hline}

{marker title}{...}
{title:Title}

{p2colset 5 21 23 2}{...}
{p2col:{bf:beyondpareto} {hline 2}}Optimal extreme-value index estimation
based on rank-size regression and asymptotic mean squared error minimization
for threshold choice of upper-order statistics{p_end}


{marker contents}{...}
{title:Table of contents}

	{help beyondpareto##syntax:Syntax}                
	{help beyondpareto##description:Description}  
	{help beyondpareto##options:Options}
	{help beyondpareto##examples:Examples}
	  {help beyondpareto##ex_1a:Example 1a: Fitting a joint Pareto and lognormal distribution} 
	  {help beyondpareto##ex_1b:Example 1b: Fitting a Burr distribution}  
	  {help beyondpareto##ex_1c:Example 1c: Top-censoring in income distribution (GB2 model)}
	  {help beyondpareto##ex_2:Example 2: Fitting German city sizes}
	{help beyondpareto##results:Stored results}
	{help beyondpareto##references:References}  
	{help beyondpareto##authors:Authors}  
	{help beyondpareto##see:Also see}  


{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmd:beyondpareto}
{varname}
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 15}{...}
{synopthdr}
{synoptline}
{synopt: {opt nrange(#,#)}}set minimum and maximum absolute sample size in the
tail of wealthiest units considered in the analysis, for example,
{cmd:nrange(20,400)}; options {cmd:nrange()} and {cmd:fracrange()} are mutually exclusive{p_end}
{synopt: {opt fracrange(#,#)}}similar to {cmd:nrange()} but given as ratio of the
complete sample size, for example, {cmd:fracrange(0.05, 0.2)}{p_end}
{synopt: {opt rho(#)}}set second-order parameter of regular variation; default
is {cmd:rho(-0.5)}; possible values are real negative numbers{p_end}
{synopt: {opt plot(string)}}options are {cmd:pareto}, {cmd:gamma}, {cmd:amse},
or {cmd:all}, which displays a combined graph of the quantile-quantile (QQ)
Pareto, gamma, and asymptotic mean squared error (AMSE) plots{p_end}
{synopt: {opt size(string)}}to control the overall size of the graph as in
{manhelpi region_options G-3}, set {cmd:size(xsize(}{it:#}{cmd:))},
{cmd:size(ysize(}{it:#}{cmd:))}, or both via {cmd:size(xsize(}{it:#}{cmd:) ysize(}{it:#}{cmd:))}{p_end}
{synopt: {opt save(string)}}plots will be saved; supply syntax for {helpb graph export} here{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weights}.  The given weighting scheme is
interpreted as sampling weights and recentered to sum to the number of
observations; see further explanation under
{help beyondpareto##description:{it:Description}}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:beyondpareto} estimates an optimally selected extreme-value index, gamma,
following the method in Schluter (2018, 2021).  The reciprocal of gamma is
often referred to as the tail exponent or Pareto shape parameter.  The
selection takes place via the minimization of the AMSE, which is a weighted
sum of bias and variance of the estimated tail coefficient.

{pstd}
The basic structure of the program is the following: First, the dataset is
ordered from the largest to the smallest of the values of the variable passed
in {varname}.  Second, for each of the observations ranked in this way, the
extreme-value index gamma and the AMSE are calculated (Beirlant, Vynckier, and
Teugels 1996).  Third, the observation with the minimum AMSE is selected, and
the optimal extreme-value index estimate, the standard error, and the 95%
normal confidence interval are displayed.  Fourth, if chosen, three diagnostic
plots are displayed.{p_end}

{pstd}
The extreme-value index gamma is obtained by running a least-squares
regression on the coordinates of the Pareto QQ plot, which is a type of
rank-size plot.  This estimation technique has the advantage of being more
efficient than other standard maximum-likelihood estimation or
regression-based techniques.  If the dataset comes with sampling weights (such
as survey data), then the estimator of gamma is computed using a weighted
distribution function.{p_end}

{pstd}
Note: If the user wishes to run only one rank-size regression for a fixed
threshold k, for example 500, this can be achieved by setting the option
{cmd:nrange(500,500)}.{p_end}

{pstd}
{cmd:beyondpareto} is compatible with Stata version 11.2 or later.  Please
note that examples were produced using Stata 18.  Earlier versions may produce
different random numbers or may not provide the functionality used in the
examples.


{marker options}{...}
{title:Options}

{phang}
{opt nrange(#,#)} determines the minimum and maximum absolute number (a,b) of
upper-order statistics considered for optimal threshold selection and for
estimation of the extreme-value index, where 2<=a<=b<=n, with n being the
number of observations.  It thereby also determines the upper limit of the
possible thresholds that can be selected because the first value a
corresponds to the highest upper-order statistic considered for threshold
selection, that is, the origin of the Pareto QQ plot.  The minimum a should
not be set lower than 2.  The options {cmd:nrange()} and {cmd:fracrange()} are
mutually exclusive.{p_end}

{phang}
{opt fracrange(#,#)} determines, in terms of fractions (p,q) of the
sample, the minimum and maximum of upper-order statistics considered for
optimal threshold selection and for estimation of the extreme-value index,
where 0<p<=q<=1.  That is, if {cmd:fracrange()} is set to (0.05, 0.3), then
the fraction of observations considered for tail estimation in total is the
upper 30% of observations but taking a minimum of 5% of upper-order
statistics.  Other than {cmd:nrange()}, {cmd:fracrange()} accounts for weights
and determines the absolute minimum and maximum sample sizes for tail
estimation as weighted values.  If neither {cmd:nrange()} nor
{cmd:fracrange()} is set by the user, then {cmd:fracrange(0.025, 0.2)} is
used.{p_end}

{phang}
{opt rho(#)} sets the the so-called second-order parameter of regular
variation.  See Schluter (2021) for a precise definition.  In brief, we can
state that as {cmd:rho()} falls in magnitude, the nuisance function associated
with the distribution of the outcome decays more slowly.  That is, as
{cmd:rho()} falls in magnitude, we will expect more asymptotic distortions in
the estimator of the extreme-value index.  The choice of {cmd:rho()} will
influence the bias correction of the estimate of the extreme-value index.
However, the choice of {cmd:rho()} should generally have little-to-negligible
influence on the final results in areas where the Pareto QQ plot has become
approximately linear.  Accordingly, choosing different levels of {cmd:rho()}
can be used for a sensitivity analysis.  {it:#} should be smaller than zero.
Common values for sensitivity analyses are -0.5, -1, and -2.{p_end}

{phang}
{opt plot(string)} specifies that one of the following three diagnostic plots
or a combined graph of all three plots be produced (from left to right): 1)
Pareto QQ plot, 2) extreme-value index (gamma) plot, and 3) AMSE plot.
Possible values are {cmd:pareto}, {cmd:gamma}, {cmd:amse}, and {cmd:all}.
Set, for example, {cmd:plot(pareto)} if only the Pareto QQ plot is needed.  The
AMSE plot shows the calculated AMSE on the ordinate and the upper-order
statistics (k) on the abscissa along with the selected upper-order statistic
that gives the minimum AMSE.  The extreme-value index plot shows the estimated
values of gamma and their 95% confidence intervals for all values of the
upper-order statistics considered for estimation.  It also marks the selected
upper-order statistic that gives the minimum AMSE.  The Pareto QQ plot shows
normalized sizes on the ordinate and ranks on the abscissa.  For a precise
definition of the Pareto QQ plot, see Schluter (2021).  The plot also shows
the line that has been fit to the Pareto QQ plot based on the optimally
selected threshold and the associated estimate of the extreme-value index.
The Pareto QQ plot is restricted to the fraction or number of observations set
as upper bound in {cmd:nrange()} or {cmd:fracrange()}.{p_end}

{phang}
{opt size(string)} specifies the size of the graph.  The syntax is identical
to {manhelpi region_options G-3}, and one can set
{cmd:size(xsize(}{it:#}{cmd:))}, {cmd:size(ysize(}{it:#}{cmd:))}, or both via
{cmd:size(xsize(}{it:#}{cmd:)} {cmd:ysize(}{it:#}{cmd:))}.{p_end}

{phang}
{opt save(string)} specifies that the plotted graph be saved under a supplied
filename, which needs to be given as {it:newfilename}{cmd:.}{it:suffix}, where
{it:suffix} can be chosen from the list of formats given in
{helpb graph export} along with other options.  This option saves only the
graph in combination with {cmd:plot()}.{p_end}


{marker examples}{...}
{title:Examples}

    {marker ex_1a}
    {title:Example 1a: Fitting a joint Pareto and lognormal distribution}

{pstd}
We generate a basic dataset with two parts: one that is based on a Pareto
distribution and one that is based on a lognormal distribution.{p_end}
{phang2}{cmd:. set seed 330033}{p_end}
{phang2}{cmd:. set obs 5000}{p_end}
{phang2}{cmd:. generate wealth = exp(rnormal(5,2))}{p_end}
{phang2}{cmd:. summarize wealth}{p_end}
{phang2}{cmd:. local max_l = r(max)}{p_end}
{phang2}{cmd:. sort wealth}{p_end}
{phang2}{cmd:. replace wealth = . if _n >= 3000}{p_end}

{phang2}{cmd:. generate un = runiform() if wealth == .}{p_end}
{phang2}{cmd:. summarize wealth}{p_end}
{phang2}{cmd:. local max_l = r(max)}{p_end}
{phang2}{cmd:. replace wealth = ((1-un)^(-1/0.85))*`max_l' if wealth == .}{p_end}
{phang2}{cmd:. drop un}{p_end}
{phang2}{cmd:. generate weight = 1}{p_end}

{pstd}
Now we can fit this distribution using the {cmd:beyondpareto} command and draw
the three diagnostic plots.{p_end}
{phang2}{cmd:. beyondpareto wealth [w=weight], nrange(10,5000) rho(-0.5) plot(all)}{p_end}

{pstd}
{cmd:beyondpareto} is able to determine that the Pareto tail lies above
observation 3,000.{p_end}

{marker ex_1b}
    {title:Example 1b: Fitting a Burr distribution}

{pstd}
We generate a Burr distribution, which is often also called Singh-Maddala
distribution (Singh and Maddala 1976).{p_end}

{pstd}
This distribution is heavy tailed, similarly to a Pareto distribution.  In
fact, the Burr distribution nests the Pareto type II distribution as a special
case.  Furthermore, as noted in Schluter (2021), the Burr distribution is
contained in the Hall class of distributions, meaning that they are Paretian
up to a nuisance function that converges to a constant with a polynomial
rate.{p_end}

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set seed 330033}{p_end}

{phang2}{cmd:. local gam = 0.6}{p_end}
{phang2}{cmd:. local rho = -2}{p_end}

{phang2}{cmd:. set obs 20000}{p_end}
{phang2}{cmd:. generate un = runiform()}{p_end}
{phang2}{cmd:. generate wealth = (un^`rho' - 1)^(-`gam'/`rho')}{p_end}
{phang2}{cmd:. generate weight = 1}{p_end}

{pstd}
We have generated the data with {cmd:rho} = -2, so tail convergence to a
Paretian distribution is rather fast.  We now estimate the optimal gamma with
several specifications of {cmd:rho()}.{p_end}

{phang2}{cmd:. beyondpareto wealth [w=weight], nrange(10,10000) rho(-0.5)}{p_end}
{phang2}{cmd:. beyondpareto wealth [w=weight], nrange(10,10000) rho(-1)}{p_end}
{phang2}{cmd:. beyondpareto wealth [w=weight], nrange(10,10000) rho(-2)}{p_end}

{pstd}
Estimation is very robust to the choice of {cmd:rho()}, but the best estimate
of gamma is generally achieved by choosing the underlying {cmd:rho}.{p_end}

{marker ex_1c}
    {title:Example 1c: Top-censoring in income distribution (GB2 model)}

{pstd}
GB2 distribution models provide a very good fit for local earning
distributions, and we use this example to demonstrate how to handle censored
data as they often appear in income distributions from, for example,
administrative data.  We generate a dataset based on the GB2 distribution
using the parameter estimates as given in Schluter and Trede
(2024).{p_end}

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set seed 330033}{p_end}

{phang2}{cmd:. local b = 5.18}{p_end}
{phang2}{cmd:. local a = 32754}{p_end}
{phang2}{cmd:. local p = 0.518}{p_end}
{phang2}{cmd:. local q = 0.509}{p_end}

{phang2}{cmd:. set obs 140000}{p_end}
{phang2}{cmd:. generate double income = `a'*( (1/invibeta(`p',`q',runiform()))-1 )^(-1/`b')}{p_end}

{phang2}{cmd:. summarize income}{p_end}

{phang2}{cmd:. gsort - income}{p_end}
{phang2}{cmd:. generate weight = 1}{p_end}

{phang2}{cmd:. display "population gamma: " 1 / (`b' * `q') /* .37927346 */}{p_end}

{phang2}{cmd:. beyondpareto income, fracrange(.0001,.2) rho(-0.5) plot(all)}{p_end}

{pstd}
Next we investigate the effect of top-censoring on the estimator, imposing a
censoring incidence of 12% (a typical value that is used in the German
administrative SIAB data).

{phang2}{cmd:. local n_cens = (.12 * _N)}{p_end}
{phang2}{cmd:. drop if _n < `n_cens' /* 12% censoring & dropping */}{p_end}

{pstd}
Because the distribution now has a mass point at the censoring threshold, we
change the weight of one such worker and drop the remaining censored
observations.{p_end}

{phang2}{cmd:. replace weight = weight + `n_cens' if _n==1}{p_end}

{phang2}{cmd:. beyondpareto income [w=weight], fracrange(.003,.2) rho(-0.5) plot(all)}{p_end}

{pstd}
Despite such a large censoring incidence, {cmd:beyondpareto} performs well in
estimating the rank-size regressor.{p_end}

{pstd}
However, if the censoring problem is not properly addressed (by either
ignoring it or dropping all censored observations), the estimator will be
biased toward zero:{p_end}

{phang2}
{cmd:. beyondpareto income, fracrange(.003,.2) rho(-0.5) /* unweighted (wrong) */}{p_end}


{marker ex_2}
    {title:Example 2: Fitting German city sizes}

{pstd}
Now we apply {cmd:beyondpareto} to German city size data.  The distribution of
city sizes is generally also not strictly Pareto but still rather
Pareto-like.{p_end}

{phang2}{cmd:. clear all}{p_end}

{phang2}{cmd:. import excel using "https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/Archiv/GVAuszugJ/31122000_Auszug_GV.xlsx?__blob=publicationFile", sheet(Gemeindedaten) cellrange(J8:J16155)}{p_end}

{phang2}{cmd:. rename J citysize}{p_end}
{phang2}{cmd:. drop if citysize == .}{p_end}
{phang2}{cmd:. keep if citysize > 1}{p_end}
{phang2}{cmd:. generate weight = 1}{p_end}

{phang2}{cmd:. beyondpareto citysize [w=weight], fracrange(0.001, 0.5) rho(-0.5) plot(all)}{p_end}

{pstd}
We obtain a value of gamma=0.761, which is the same as the estimate in
Schluter (2021).  As we can see from the diagnostic plots, this value appears
sensible because the plot for gamma is very flat and stable.  Then it becomes
optimal to choose a value that minimizes the variance of the estimate of
gamma.{p_end}

{pstd}
The German Federal Statistical Office's landing page for the city size data is
 {browse "https:www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/_inhalt.html"}.

{pstd}
To adapt the data access path for the years up to 2013, simply adjust the date
in the access path, for example, {cmd:31122013}.  For all subsequent years,
one has to additionally adjust the sheet name and cell range; for example, for
the year 2014, we need {cmd:sheet(Onlineprodukt_Gemeinden_311214)} and
{cmd:cellrange(J10:J16059)}.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:beyondpareto} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(Ybase)}}value of the variable given in varname at the threshold of the tail, that is, the upper-order statistic associated with the lowest AMSE{p_end}
{synopt:{cmd:e(kbase)}}index k associated with Ybase, that is, the index associated with the minimum value of the AMSE{p_end}
{synopt:{cmd:e(AMSE)}}minimum value of the AMSE{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom after estimation used for testing{p_end}
{synopt:{cmd:e(gamma)}}value of the estimated extreme-value index{p_end}
{synopt:{cmd:e(gamma_SE)}}value of the standard error of the estimated
extreme-value index{p_end}
{synopt:{cmd:e(gamma_lo)}}lower value of the 95% confidence interval of the
estimated extreme-value index{p_end}
{synopt:{cmd:e(gamma_hi)}}upper value of the 95% confidence interval of the
estimated extreme-value index{p_end}

{p2col 5 20 24 2:Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:beyondpareto}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}matrix containing the estimated extreme-value index{p_end}
{synopt:{cmd:e(V)}}matrix containing the variance of the extreme-value index{p_end}


{marker references}{...}
{title:References}

{phang}
Beirlant, J., P. Vynckier, and J. L. Teugels. 1996. Tail index estimation,
Pareto quantile plots, and regression diagnostics. 
{it:Journal of the American Statistical Association} 91:
1659-1667. {browse "https://doi.org/10.2307/2291593"}.

{phang}
Schluter, C. 2018. Top incomes, heavy tails, and rank-size regressions.
{it:Econometrics} 6: art. 10. 
{browse "https://doi.org/10.3390/econometrics6010010"}.

{phang}
------. 2021. On Zipf's law and the bias of Zipf regressions. 
{it:Empirical Economics} 61: 529-548.
{browse "https://doi.org/10.1007/s00181-020-01879-3"}.

{phang}
Schluter, C., and M. Trede. 2024. Spatial earnings inequality. 
{it:Journal of Economic Inequality} 22: 531-550.
{browse "https://doi.org/10.1007/s10888-023-09616-3"}

{phang}
Singh, S. K., and G. S. Maddala. 1976. A function for size distribution of
incomes. {it:Econometrica} 44: 963-970.
{browse "https://doi.org/10.2307/1911538"}.


{marker authors}{...}
{title:Authors}

{pstd}
Johannes K{c o:}nig{break}
DIW Berlin{break}
Berlin, Germany{break}
jkoenig@diw.de

{pstd}
Isabella Retter{break}
DIW Berlin{break}
Berlin, Germany{break}
iretter@diw.de

{pstd}
Christian Schluter{break}
Aix Marseille School of Economics{break}
Marseille, France{break}
and{break}
University of Southampton{break}
Southampton, UK{break}
christian.schluter@univ-amu.fr


{marker see}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 25, number 1: {browse "https://doi.org/10.1177/1536867X251322969":st0770}{p_end}

{p 7 14 2}
Help:  {helpb pqqplot} (if installed){p_end}

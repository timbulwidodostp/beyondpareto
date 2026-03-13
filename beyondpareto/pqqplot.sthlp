{smcl}
{* *! version 1.1 20feb2024}{...}
{viewerjumpto "Title" "pqqplot##title"}{...}
{viewerjumpto "Table of contents" "pqqplot##contents"}{...}
{viewerjumpto "Syntax" "pqqplot##syntax"}{...}
{viewerjumpto "Description" "pqqplot##description"}{...}
{viewerjumpto "Options" "pqqplot##options"}{...}
{viewerjumpto "Examples" "pqqplot##examples"}{...}
{viewerjumpto "References" "pqqplot##references"}{...}
{viewerjumpto "Authors" "pqqplot##authors"}{...}
{viewerjumpto "Also see" "pqqplot##see"}{...}
{cmd:help pqqplot}{right: ({browse "https://doi.org/10.1177/1536867X251322969":SJ25-1: st0770})}
{hline}

{marker title}{...}
{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{bf:pqqplot} {hline 2}}Pareto quantile-quantile plot with line fit


{marker contents}{...}
{title:Table of contents}

	{help pqqplot##syntax:Syntax}                
	{help pqqplot##description:Description}  
	{help pqqplot##options:Options}
	{help pqqplot##examples:Examples}
	{help pqqplot##references:References}  
	{help pqqplot##authors:Authors}  
	{help pqqplot##see:Also see}  


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:pqqplot}
{varname}
{ifin}
{weight}{cmd:,} {opt gamma(#)} {opt base(#)} [{it:options}]

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt gamma(#)}}set the extreme-value index, corresponding to the slope of the fit line{p_end}
{p2coldent:* {opt base(#)}}set the base index, corresponding to the upper-order statistic through which the line will pass{p_end}
{synopt: {opt save(string)}}specify where the plot will be saved{p_end}
{synopt: {opt maxk(#)}}specify the number of upper-order statistics to be displayed in the plot{p_end}
{synopt: {opt size(string)}}to control the overall size of the graph as in
{manhelpi region_options G-3}, set {cmd:size(xsize(}{it:#}{cmd:))},
{cmd:size(ysize(}{it:#}{cmd:))}, or both via {cmd:size(xsize(}{it:#}{cmd:) ysize(}{it:#}{cmd:))}{p_end}
{synopt: {opt hidden_plots}}use this option if you do not want to display the
plot immediately but, for example, combine it with other plots{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {cmd:gamma()} and {cmd:base()} are required.{p_end}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weight}.  However, the weights will be
interpreted as sampling weights and recentered to sum to the number of
observations.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:pqqplot} shows the Pareto quantile-quantile (QQ) plot, that is, a
rank-size plot of a variable.  The formal definition of the Pareto QQ plot is
given in Schluter (2021).  The command also fits a line for a chosen value of
the extreme value index (gamma) and a chosen value of the relevant upper-order
statistic (k).  If the dataset comes with sampling weights (such as survey
data), the {it:x} coordinates of the rank-size plot are ranks that account for
the sampling weights.  See the appendix of K{c o:}nig, Schluter, and
Schr{c o:}der (2023).

{pstd}
{cmd:pqqplot} is compatible with Stata 11.2 or later.{p_end}


{marker options}{...}
{title:Options}

{phang}
{opt gamma(#)} specifies the assumed extreme-value index used to plot a line
for the upper tail of the data.  {cmd:gamma()} is required.

{phang}
{opt base(#)} specifies the threshold upper-order statistic beyond which the
data are assumed to become linear.  The plotted line depending on
{cmd:gamma()} also starts only at the specified base.  {cmd:base()} is
required.

{phang}
{opt save(string)} specifies that the plot be saved under a supplied filename,
which needs to be given as {it:newfilename}{cmd:.}{it:suffix}, where
{it:suffix} can be chosen from the list of formats given in
{helpb graph export}, along with other options.

{phang}
{opt maxk(#)} specifies up to which upper-order statistic the graph should be
plotted.

{phang}
{opt size(string)} specifies the size of the graph.  The syntax is identical
to {manhelpi region_options G-3}, and one can set
{cmd:size(xsize(}{it:#}{cmd:))}, {cmd:size(ysize(}{it:#}{cmd:))}, or both via
{cmd:size(xsize(}{it:#}{cmd:) ysize(}{it:#}{cmd:))}.

{phang}
{opt hidden_plots} plots the graph with the {cmd:nodraw} option so that the
graph is not visible.


{marker examples}{...}
{title:Examples: Producing a Pareto QQ plot}

{pstd}
We generate a basic dataset with two parts: one based on a Pareto distribution
and one based on a lognormal distribution.{p_end}

{phang2}{cmd:. set seed 1234}{p_end}
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
{phang2}{cmd:. generate weight=1}{p_end}

{pstd}
Now we can generate the Pareto QQ plot for different choices of the
extreme-value index gamma with a line plot fitting the largest k
observations.{p_end}

{phang2}{cmd:. pqqplot wealth [w=weight], gamma(0.5) base(50)}{p_end}
{phang2}{cmd:. pqqplot wealth [w=weight], gamma(0.4) base(50)}{p_end}
{phang2}{cmd:. pqqplot wealth [w=weight], gamma(0.4) base(100)}{p_end}

{pstd}
The same plot but displaying only the largest {cmd:maxk(200)} values.{p_end}
{phang2}
{cmd:. pqqplot wealth [w=weight], gamma(0.4) base(100) maxk(200)}{p_end}


{marker references}{...}
{title:References}

{phang}
K{c o:}nig, J., C. Schluter, and C. Schr{c o:}der. 2023. Routes to the top. 
Discussion Paper 2066, DIW Berlin.
{browse "https://doi.org/10.2139/ssrn.4692506"}.

{phang}
Schluter, C. 2021. On Zipf's law and the bias of Zipf regressions. 
{it:Empirical Economics} 61:
529-548. {browse "https://doi.org/10.1007/s00181-020-01879-3"}.


{marker authors}{...}
{title:Authors}

{pstd}
Johannes K{c o:}nig{break}
DIW Berlin{break}
Berlin, Germany{break}
jkoenig@diw.de

{pstd}
Isabella Retter, DIW Berlin{break}
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
Help:  {helpb beyondpareto} (if installed){p_end}

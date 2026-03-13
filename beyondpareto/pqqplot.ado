*! pqqplot.ado, version 1.1, 2024-09-27
*! Christian Schluter, Isabella Retter, Johannes König

*! pqqplot.ado is part of the  `beyondpareto`  suite of functions.  
*! To learn more about beyondpareto see the vignette at 
*!       https://christianschluter.github.io/beyondpareto/
*! See also Stata Journal (forthcoming): "The beyondpareto command for optimal extreme value index estimation"


********************************************************************************
*  Pareto quantile-quantile (QQ-)plot for a given extreme value index		   *
********************************************************************************

program pqqplot
	version 11.2
	
	syntax varname [if] [in] [pw], 	/// one required variable of interest, e.g. wealth, and optional sampling weights
	gamma(real)						/// extreme value index gamma
	base(integer)					/// base index, corresponding to the upper-order statistic through which the line will pass
	[save(string) 					/// if save is set then the Pareto QQ-plot is displayed and stored under the supplied filename whose extension can be chosen from the list of formats given in graph export, along with other options.
	maxk(integer 0) 				/// only the largest maxk values are displayed in the plot
	size(string)					/// to control the overall size of the graph as in region_options, e.g. size(xsize(#)), size(ysize(#)) or both, size(xsize(#) ysize(#))
	hidden_plots] 					/// use this option if you do not want to display the plot immediately but, e.g., combine with other plots

	
	marksample touse 
	
	// Store argument in wealth variable and remove missing observations
	local outname "`varlist'"
	tempvar wealth
	gen double `wealth'=`outname' if `touse'
	markout `touse' `wealth'
	qui sum `wealth' if `touse'
	if (r(N)==0) 	error 2000
	
	// Generate a temporary variable wght to store the weights. If no weights are given, we use constant weights.		
	tempvar wght

if `"`exp'"' != ""{
		display "Using the given sampling weights."
		qui{
			gen double `wght'`exp' 
			markout `touse' `wght' //set `touse' to 0 for missing values of `wght' 
			sum `wght' if `touse'
			
			if (r(N)==0) 	error 2000
			else 			local wnobs=r(N)
			
			// Normalize weights so that their average is one
			replace `wght' = `wght'/r(mean)
		}
	}
	else {
		display "No sampling weights given. Using w=1."

		qui{
			gen double `wght'  = 1  
		}

	}

	qui sum `wealth' if `touse'
	local nobs=r(N)
	
	// K is a rank variable with K=1 being the richest person
	tempvar Fbase runsumwght nn K YW
		
		
	// compute the x-coordinate of the Pareto QQ-plot
	gsort - `wealth'

	qui sum `wght' if `touse'
	qui gen `runsumwght' = sum(`wght') if `touse'

	gen `Fbase'=log((r(sum)+1)/(`runsumwght')) if `touse'
		
		
	****************
	* Plot section *
	****************

	sort `wealth', stable

	qui gen `nn' = sum(`touse') if `touse'
	qui gen `K'=`nobs'-(`nn'-1) if `touse'
	
	if "`maxk'"!="0" {
	 replace `touse'=0 if `K'>`maxk'
	}
	
	qui sum `wealth' if `K'==`base'
	local base_income= r(mean)
	gen double `YW'=log(`wealth' /`base_income') if `touse'
	label var `YW' "YW" 
	
	// Generate F and create a running variable
	gsort -`K'			
	
	// Find x-value for given k 
	qui sum `Fbase' if `K'==`base'
	local X_base= r(mean)
	tempvar Y_fit
	gen `Y_fit' = `gamma'*(`Fbase'-`X_base') if `touse'
	label var `Y_fit' "Fitted values" 

	if "`hidden_plots'"!="" & "`filename'"==""{
	local nodraw nodraw
	}

	// Plot Pareto QQ-plot
	
	qui twoway (scatter `YW' `Fbase', msize(small) msym(oh) mc(black%30)) ///
	(line `Y_fit' `Fbase' if `K'<=`base', lc(black) lp(solid) ), scheme(sj) ///
	graphregion(color(white)) `size' xtitle("Relative Rank") ytitle("Log (Y/Ybase)") ///
	xline(`X_base',  lpattern(dash) lcolor(gs0))  legend(off) name("QQ", replace) ///
	`nodraw'
		
	if "`save'"!=""{
		di "Saving plot" 
		qui graph export `save'
	}

	
end
	
	

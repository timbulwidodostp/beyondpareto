*! beyondpareto.ado, version 1.0, 2024-07-03
*! Christian Schluter, Isabella Retter, Johannes König

*! To learn more about beyondpareto see the vignette at  
*!       https://christianschluter.github.io/beyondpareto/
*! See also Stata Journal (forthcoming): "The beyondpareto command for optimal extreme value index estimation"

*********************************************************************************
* Estimating the extreme value index for Pareto-like distributions by minimzing * 
* the asymptotic mean-squared error as optimal trade off between bias and 		*	
* variance of the Zipf (rank-size) regression.									*	
*********************************************************************************

program beyondpareto, eclass sortpreserve
	version 11.2
	
	syntax varname [if] [in] [pw],		/// one required variable of interest, e.g. wealth, and optional sampling weights
	[nrange(numlist sort min=2 max=2 >1 integer) /// minimum and maximum absolute sample size in the tail of wealthiest units considered in the analysis. e.g. nrange(20,400)
	fracrange(numlist sort min=2 max=2 <=1 >0)  /// like nrange but given as ratio of the complete sample size, e.g. fracrange(0.05, 0.2)
	rho(real -0.5)								/// parameter of second-order regular variation, rho<0
	plot(string)		 						/// options are pareto, gamma, amse or all, which displays a combined graph of the QQ pareto plot, gamma and AMSE plot.
	size(string)								/// to control the overall size of the graph as in region_options, e.g. size(xsize(#)), size(ysize(#)) or both, size(xsize(#) ysize(#))
 	save(string)]								/// if save is set then the graph plot as specified in the option plot() is displayed and stored 
												/// under the supplied filename whose extension can be chosen from the list of formats given in graph export, along with other options. Only works in combination with the plot-option.
											
								
	tempvar wealth wght K Fbase element Results
	
	// Store argument in wealth variable and remove missing observations.
	local outname "`varlist'"
	gen double `wealth'=`outname' 
	
	marksample touse
	markout `touse' `wealth'  //set `touse' to 0 for missing values of `wealth' 

	qui sum `wealth' if `touse'
	if (r(N)==0) 	error 2000

	// Generate a temporary variable wght to store the weights. If no weights are given, we use constant weights.		

	if `"`exp'"' != ""{
		display "Using the given sampling weights."
		qui{
			gen double `wght'`exp' 
			markout `touse' `wght' //set `touse' to 0 for missing values of `wght' 
			sum `wght' if `touse'
			
			if (r(N)==0) 	error 2000
			else 			local nwobs=r(N)
			
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
	
	if "`nrange'"!="" {
		if "`fracrange'"!="" {
			display as error "nrange and fracrange are mutually exclusive. "///
			"Please specify only one option."	
			exit 198	
		}
		else {
			local cnt=1
			foreach x in `nrange'{
				if `cnt'==1 local min=`x'
				if `cnt'==2 local end=`x'
				local cnt=`cnt'+1
			}
		}		
	}
	else if  "`fracrange'"!="" {
		local cnt=1
			foreach x in `fracrange'{
				if `cnt'==1 local min=round(`x'*`nobs')
				if `cnt'==2 local end=round(`nobs' *`x')
				local cnt=`cnt'+1
			}
		
	}
		
	// default considered for the Pareto tail is min. 2,5%, max. 20%  
	else {
		local min = max(round(0.025*`nobs'), 2)
		local end = round(`nobs' * 0.2)
		di in red "Using default values for the analysis of 2 to 20 percent " ///
				  "for the Pareto tail estimation. Please provide other " ///
				  "values using the nrange or fracrange option."
	}
	
	// Check assertions on user-provided parameters
	
	if (`min'<2){
		display as error "The minimum absolute sample size of the Pareto tail " ///
		"needs to be an integer larger or equal to 2. Please choose fracrange" ///
		" or nrange accordingly."
		exit 198
	}
	if (`min'>`nobs'){
		display as error "The minimum absolute sample size of the Pareto tail " ///
		"needs to be an integer larger or equal to 2 and smaller or equal to " /// 
		" the number of oberservations. Please choose fracrange" ///
		" or nrange accordingly."
		exit 198	
	}
	if (`end'>`nobs'){
		display as error "The maximum absolute sample size of the Pareto tail " ///
		"may not exceed the number of oberservations. " /// 
		" Please choose fracrange or nrange accordingly."
		exit 198	
	}
	

	if(`rho'>=0) {
		display as error "The parameter of second-order regular variation (rho) " ///
		"needs to be smaller than 0."
		exit 198
	}
	
	if  "`plot'"!="" & "`plot'"!="all" & "`plot'"!="amse" &  "`plot'"!="gamma" & "`plot'"!="pareto" {	
		display as error "For the option plot, please select one of the " ///
		"options pareto, gamma, amse or all."
		exit 198
	}

	
	local num_ks = `end'-`min'+1
	
	di "Considering the top `end' of `nobs' values, starting from the first `min' and " ///
		"testing `num_ks' values for k base."
	

	*************************************************************************
	* Compute the extreme value index gamma for all choices of k and choose * 
	* the one minimizing the asymptotic mean squared error				    *
	*************************************************************************
	
	// Sort wealth in descending order 
	gsort - `wealth'
	mata: rslts_min_base =J(`nobs',4,.)
	
	local min = `min'
	mata: X_all = st_data(.,("`wealth'", "`wght'"), "`touse'")
	forvalues k = `min'/`end' {
		mata:  rslts_min_base[`k', .]=paretoatk(X_all, `k', `nobs', `rho')
	}
	
	// Determine the optimal base index
	mata{	
		minindex(rslts_min_base[., 2], 1, opt_idx_base="", w="")
		res_k = rslts_min_base[opt_idx_base,.]
		opt_base =  res_k[1,1]
		st_numscalar("optbase",opt_base)
		st_store(., st_addvar("double", temp_names = st_tempname(4)), "`touse'", rslts_min_base)
	}

	// Add variables to store relevant information from the optimization step	
	local col_names_list k AMSE gamma_hat sd 
	local num_add_cols : word count `col_names_list'
	forval j = 1/`num_add_cols' {
		local varname : word `j' of `col_names_list'
		mata: st_local("`varname'",temp_names[`j'])
	}

	local optbase = optbase

	// Generate confidence interval for gamma_hat
	tempvar gamma_hi gamma_lo
 	qui{
		gen `gamma_hi'=`gamma_hat'+1.96*`sd'
		gen `gamma_lo'=`gamma_hat'-1.96*`sd'
		
		gen `Results'="`outname'" if `k'==optbase
		tempvar SE
		gen `SE'=`sd'
	}
	
	label var `wealth' "Ybase" 
	label var `SE' "S.E."
	label var `gamma_hat' "gamma"
	label var `gamma_lo' "[95% Conf."
	label var `gamma_hi' "Interval]"
	label var `Results' "Results"
	
	tabdisp `Results' if `k'==optbase, c(`wealth' `gamma_hat' `SE' `gamma_lo' `gamma_hi') 
	local opt_k=`optbase'-1
	di as text "Optimal k base: " as result `optbase'
	

	*******************
	*  Plot section   *
	*******************
	
	// We plot 
	// - the asymptotic mean squared error (AMSE) resp.
	// - gamma over the number of top k chosen incomes and mark the optimal k, and
	// - the Pareto QQ-Plot using optimal extreme value index gamma
	
	if "`plot'"=="" & "`save'"!=""{
		di in red "No plots are selected. Please set plot()-option to select " ///
		"which plot to save."
	}
	
	if ( "`plot'"!=""){	
		qui sum `gamma_hat' if `k'==`optbase'
		local gamma_hat_opt = r(mean)
		
		// Plot AMSE, gamma and Pareto-QQ plot 		
		if "`plot'"=="amse"{
			qui tw line `AMSE' `k' if inrange(`k',`min',`end'), scheme(sj) graphregion(color(white)) /// 
			xtitle(k) ytitle(AMSE) xline( `optbase', lpattern(dash) lcolor(gs0)) name(AMSE, replace)  `size'
		}	
		
		if "`plot'"=="gamma"{
			qui tw line `gamma_hat' `k' if inrange(`k',`min',`end') || ///
			line `gamma_hi' `k' if inrange(`k',`min',`end'), lp(dash) || /// 
			line `gamma_lo' `k' if inrange(`k',`min',`end'), lp(dash) , ///
			scheme(sj) graphregion(color(white)) xtitle(k) ytitle(gamma) ///
			xline( `optbase',  lpattern(dash) lcolor(gs0)) legend(off) name(gamma, replace)  `size'
		}
		
		if "`plot'"=="pareto"{
			qui pqqplot `wealth' if `touse' [w=`wght'], gamma(`gamma_hat_opt') base(`optbase') maxk(`end') size(`size')
		}
		
		if "`plot'"=="all" {	
			if "`size'"== ""{
				local size xsize(10)
			}
			qui tw line `AMSE' `k' if inrange(`k',`min',`end'), scheme(sj) graphregion(color(white)) /// 
			xtitle(k) ytitle(AMSE) xline( `optbase', lpattern(dash) lcolor(gs0)) name(AMSE, replace) nodraw
			
			qui tw line `gamma_hat' `k' if inrange(`k',`min',`end') || ///
			line `gamma_hi' `k' if inrange(`k',`min',`end'), lp(dash) || /// 
			line `gamma_lo' `k' if inrange(`k',`min',`end'), lp(dash) , ///
			scheme(sj) graphregion(color(white)) xtitle(k) ytitle(gamma) ///
			xline( `optbase',  lpattern(dash) lcolor(gs0)) legend(off) name(gamma, replace) nodraw
			
			qui pqqplot `wealth' if `touse' [w=`wght'], gamma(`gamma_hat_opt') base(`optbase') maxk(`end') hidden_plots
			
			qui graph combine QQ gamma AMSE, rows(1) graphregion(color(white)) `size' 

		}
		
		if "`save'"!=""{
			di "Saving plots"
			qui graph export `save'
		}

	}
	
qui{
		local dfr=`optbase'-2 // select optimal k and then -1 for estimated gamma

		tempname b V
		sum `gamma_hat' if `k'==`optbase'
		matrix `b' =r(mean)         
		
		sum `sd' if `k'==`optbase'
		matrix `V' = r(mean)*r(mean)
		
		matrix colnames `b' = "gamma"
		matrix rownames `V' = "gamma"
		matrix colnames `V' = "gamma"

		ereturn post `b' `V', esample(`touse') // clear previous estimates and return sample

		ereturn scalar kbase = `optbase'
		
		sum `wealth' if `k'==`optbase'
		ereturn scalar Ybase=r(mean)
		
		sum `gamma_hat' if `k'==`optbase'
		ereturn scalar gamma=r(mean)
		
		sum `sd' if `k'==`optbase'
		ereturn scalar gamma_SE=r(mean)
		
		sum `gamma_lo' if `k'==`optbase'
		ereturn scalar gamma_lo=r(mean)
		
		sum `gamma_hi' if `k'==`optbase'
		ereturn scalar gamma_hi=r(mean)	
		
		sum `AMSE' if `k'==`optbase'
		ereturn scalar AMSE=r(mean)	
		
		ereturn scalar df_r=`dfr'
		
	    ereturn local cmd "beyondpareto"
	}	

end



mata:
numeric matrix paretoatk(numeric matrix X_all, real scalar k, real scalar nobs, real scalar rho)
{
			J1k = 1::k
			// Jk vector of dim. k of ones
			Jk = J(k, 1, 1)
			

			X = X_all[1::k,.]
			
			//X = st_data((1, k),("`wealth'", "`wght'"), "`touse'")
			//, st_varindex("`touse'"))
			weight_running_sum = runningsum(X[.,2])
			
			// x-coordinate of Pareto QQ plot
			Fbase = log((nobs+1)*Jk:/weight_running_sum)
			
			XW = log(weight_running_sum[k,1]*Jk:/weight_running_sum)
			base_income = X[k,1]
			YW= log(X[.,1]:/(base_income*Jk))
			
			// Computing the OLS estimator
			gamma_hat = (XW'*YW)/(XW'*XW)
			
			// Residuals 
			rsdls = YW-gamma_hat*XW
			
			// Generate weights w = w1,w2 for the computation of the AMSE
			w = Jk, (1::k):/(Jk*(k+1)) 
			ssr = w:*rsdls:^2
			ssr_mean = colsum(ssr)/k
			frc = ((J1k:/((k+1)*Jk)):^((-1)*rho)-1*Jk):/(rho*Jk)
			d_tilde=colsum(w:*(frc:^2))/k
			d = d_tilde*(2*(1-1*rho)^2)^2/(2-1*rho)^2

			frc = Jk:/J1k
			frc_rev = frc[k::1]

			rs_frc_rev = runningsum(frc_rev)
			rs_frc_rev_rev = rs_frc_rev[k::1]
			
			rs2_frc_rev = runningsum(frc_rev:^2)
			rs2_frc_rev_rev = rs2_frc_rev[k::1]
			
			c_brackets = rs2_frc_rev_rev   ///
						+ ((rs_frc_rev_rev-log((k+1):/J1k)):^2)

			c_tilde = colsum(w:*c_brackets)
			c = c_tilde*4/5
			
			// Solve for unknown coefficients
			coeffs=lusolve((c \ d), (1 \ 1))
			
			// Asymptotic mean squared error
			AMSE = sum(coeffs':*ssr_mean)
			
			// Standard deviation
			sd = sqrt((5/4*gamma_hat^2)/k)
			return (k, AMSE, gamma_hat, sd)  
}
end
	
	

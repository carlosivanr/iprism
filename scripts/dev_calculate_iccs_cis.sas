/* Libref */

proc import datafile="C:\Users\rodrica2\OneDrive - The University of Colorado Denver\Documents\DFM\projects\iPRISM\data\icc_test.csv"
     out=df
     dbms=csv
     replace;
     getnames=yes;
run;

/* Model works great */
ods output CovParms=covp;
proc mixed data = work.df covtest;
      class teamcode;
      model Reach = /s;
      random intercept/subject = teamcode;
run;


/* Troubleshoot code*/
%let data = work.df;
%let i = 4;
%let out=all_boot_vcs;

proc print data=&data;
run;

%macro bootstrap_vc(data=, out=, reps=1000);

%do i = 1 %to &reps;
    /* Resample with replacement */
    proc surveyselect data=&data out=boot_sample method=urs samprate=1 outhits seed=&i noprint;
        id _all_;
    run;

    /* Drop rows where only one value per team code is randomly selected */
    proc sql;
        create table boot_sample_clean as
        select *
        from boot_sample
        group by teamcode
        having count(*) > 1;
    quit;

    /* Refit the model to the bootstrap sample */
    proc mixed data=boot_sample_clean;
        class teamcode;
        model Reach = /s;
        random intercept/subject = teamcode;
        ods output CovParms=boot_vc;
    run;


    /* Add iteration label and append results */
    data boot_vc;
        set boot_vc;
        iteration = &i;
    run;

    proc append base=&out data=boot_vc force; run;

%end;

%mend;


%bootstrap_vc(data=work.df, out=all_boot_vcs, reps=1000);


/* Calculate standard deviations */
proc sql;
    create table boot_vc_summary as
    select 
        CovParm,
        mean(Estimate) as Mean_Estimate,
        std(Estimate) as SE_Estimate
    from all_boot_vcs
    group by CovParm;
quit;


/* plice in the bootstrapped SEs to the covp table for it to be plug and play with the remaining code */
proc sql;
    create table covp_boot as
    select 
        a.CovParm,
        a.Estimate,
        b.SE_Estimate as StdErr  /* Use bootstrap SE instead of model-based */
    from CovP as a
    left join boot_vc_summary as b
    on a.CovParm = b.CovParm;
quit;



data icc_jun;
      set covp_boot;
      retain bvar var_bvar;
      
      if CovParm = "Intercept" then do;
        bvar = Estimate; /* Between-group variance */
        var_bvar = StdErr**2; /* Variance of between-group variance */
      end;
      
      if CovParm = "Residual" then do;
        wvar = Estimate; /* Within-group variance */
        var_wvar = StdErr**2; /*Variance of within-group variance*/

        /* Compute ICC */
        icc = bvar / (bvar + wvar);

        /* Compute Variance of ICC using Jun's method */
        var_icc = var_bvar * ((wvar**2) / (wvar + bvar)**4) + var_wvar * ((bvar**2) / (wvar + bvar)**4);
        se_icc = sqrt(var_icc);  /* Standard error of ICC */

        /* Compute 95% Confidence Interval */
        icc_LCL = icc - (1.96 * se_icc); /* Lower bound */
        icc_UCL = icc + (1.96 * se_icc); /* Upper bound */

        output;
      end;
    run;

    proc print data=icc_jun;
      var icc var_icc se_icc icc_LCL icc_UCL;
      title "ICC, Variance, SE, and 95% Confidence Interval (Delta Method)";
    run;

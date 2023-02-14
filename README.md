# Associations between Body Mass Index, Weight Loss, and Overall Survival in Patients with Advanced Lung Cancer

This work has been published in *Journal of Cachexia, Sarcopenia and Muscle*. Please check <a href= "https://onlinelibrary.wiley.com/doi/abs/10.1002/jcsm.13095">here</a> for more details.

##INTRODUCTIONS
Weight loss (WL) has been associated with shorter survival in patients with advanced cancer, while obesity (high BMI) has been associated with longer survival.  The integration of BMI/WL provides a potentially powerful prognostic tool, but has not been well studied in patients with lung cancer.

##METHODS
We reviewed individual patient data (n=10,128) from advanced NSCLC and SCLC trials (n=63) of six national cancer cooperative groups.  Different values of BMI and percent WL from this cohort were used to create risk matrices for survival. These matrices were further simplified into grades based on median survival.  Relationship between survival and BMI and percent WL was examined using Kaplan-Meier product estimators and Cox proportional hazards (PH) models with restricted cubic splines for BMI. 

##RESULTS
For NSCLC, a twofold difference was noted in median survival between the BMI >28/WL ≤5% group (13.5 months) compared to BMI <20/WL >5% group (6.6 months).  These associations were less pronounced in SCLC ranging from 12.9 to 9.5 months.  Kaplan-Meier curves showed significant survival differences between grades for both NSCLC and SCLC (log-rank, p < 0.0001).  In Stage IV NSCLC, Cox PH analyses with restricted cubic splines demonstrated significant associations between BMI and survival in both WL ≤5% (p = 0.0004) and >5% (p = 0.0129) groups, as well as in WL >5% in Stage III (p = 0.0306).  In SCLC, the relationships were more complex in limited stage, but similar trends were seen in extensive stage.

##CONCLUSIONS
Both body composition (BMI) and weight loss at diagnosis have a strong association with overall survival in patients with advanced lung cancer, receiving chemotherapy with or without radiation, with a greater impact seen in NSCLC versus SCLC.  The integration of a BMI/WL grading scale may provide additional prognostic information in the evaluation of therapeutic interventions in future clinical trials.

##Files

- `Data Preprocessing.Rmd`
  - Assembles and cleans the dataset from six national cancer cooperative groups with non-small cell lung cancer(NSCLC)and small cell lung cancer (SCLC) patients

- `Survival Analysis.sas`
  - uses the Kaplan-Meier estimator, and Cox proportional hazards models with and without restricted cubic splines, with BMI and WL as continuous variables and stratification factors, respectively. 
  - performs Restricted cubic splines to examine the non-linear effects of BMI on survival in different WL subgroups
  
  
  

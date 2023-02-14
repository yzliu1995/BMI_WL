/*
Author: Yingzhou Liu <yingzhou.joe.liu@alumni.duke.edu>
Last Update Date: 01/28/2021
*/

/*
*Set up directory ;
libname in '/folders/myfolders/sasuser.v94';
*/

*Formating;
proc format;

	value subgroup 
	1 = 'NSCLC Stage III'
	2 = 'NSCLC Stage IV frontline'
	3 = 'Limited SCLC'
	4 = 'Extensive SCLC';
	
	value wgt_losspct
	1 = 'Weight loss  <= 5 %'
	2 = 'Weight loss  > 5 %';
	
    value race
        1 = 'other'
        2 = 'other' 
        3 = 'Black or African American'
        4 = 'other'
        5 = 'White'
        6 = 'other'
        7 = 'other'
        99 = 'other';
        
    value histology
        1 = 'Small cell lung cancer'
        2 = 'Adenocarcinoma'
        3 = 'Squamous'
        4 = 'other'
        5 = 'other'
        6 = 'other'
        7 = 'other'
        8 = 'other'
        99 = 'other';
        
	value ps
        0 = 'Fully active'
        1 = 'Ambulatory, capable of light work'
        2 = 'In bed < 50% of time, capable of self-care but not of work activities'
        3 = 'In bed > 50% of time, capable of only limited self-care';
        
	value age
		low-60 = 'age <= 60'	
		60<-<70 = '60 < age < 70'
		70-high = 'age >=70';
		
	value gender
		1 = 'male'
		2 = 'female';
		
    value bmi
    low-<20 = 'BMI < 20'
    20-<22 = '20<=BMI<22'
    22-<25 = '22<=BMI<25'
    25-<28 = '25<=BMI<28'
    28-high = 'BMI>=28';
    
    value disease
    1 = 'Advanced'
    0 = 'Early';
		
run;

/*
* data preprocessing, R code also provided;

data mydata;
set in.patient_5groups;

*exclude specific trials;
if protocol ne  '9761' and protocol ne '9134'
and protocol ne '9238' and protocol ne '9334'
and protocol ne '9335' and protocol ne '9633'
and protocol ne '39802' and protocol ne '39803'
and protocol ne '9309' and protocol ne '952451'
and protocol ne 'Z0030' and protocol ne 'Z4032'
and protocol ne 'S9900' and protocol ne 'E3590';

*choose initial stage above 3 below 99 / sclc stage avaiable while initial stage is missing / specific trials;
if (stage_initial >=3 and stage_initial < 99) or (stage_initial = . and not missing(sclc_stage)) or 
protocol = 'E2596' or protocol = 'E7593' or protocol = 'N0423' or protocol = 'E2597' or protocol = '892451' 
or protocol = '30004'or protocol = '982453' or protocol = 'E3503' or protocol = 'N9921' or protocol = 'E1594' 
or protocol = '39902' or protocol = '892451' or protocol = '972051' or protocol = 'N0923'
or protocol = 'N0426' or protocol = '892051' or protocol = '892052';

*exclude other protocols;
if protocol ~= '0214' and protocol ~= '30602' and protocol ~= '30607' and protocol ~='972451';

*eligible: Yes and exclude: No;
if exclude ~= 2; 
if eligible ~= 1;

*impute survdays by the date of the patient’s status record and the data of the registration;
if missing(survdays)
then survdays = status_dt - regist_dt;

*not missing survdays;
if survdays ~=.;


*add body mass index i.e., BMI;
if not missing(weight) and not missing(height)
then BMI = weight/((height/100)**2);
else
BMI = .;

*convert time to years;
time = survdays / (30.4375 * 12);

*create censoring;
if status = 2 then censor=1;
else censor = 0; 
if group = 6 and censor=0 then new_censor=1;
else if group = 6 and censor=1 then new_censor=0;
else new_censor=censor;

*age/gender/BMI not missing;
if age ~=.;
if gender ~=.;
if BMI ~=.;
* BMI not larger than 50;
if BMI <=50;

*weight loss;
if wgt_losspct ~=.;

*race;
if race = .
then race = 99;

*performance status;
if ps ~=4;
if ps ~=3;
if ps ~=.;
if ps ~=99;
run;

*create 4 groups;
*group1: NSCLC Stage III, group2: NSCLC Stage IV, group4: SCLC limited, group5: SCLC extensive);

*  NSCLC Stage III;
data group1;
set mydata;
* select trials in NSCLC Stage III;
if protocol = 'S0023' or 
protocol = 'S9429' or
protocol = 'S9712' or
protocol = '0117' or
protocol = '9410' or
protocol = '9801' or
protocol = '0214' or
protocol = '0324' or
protocol = '0617' or
protocol = '942452' or
protocol = 'N0321' or
protocol = 'N0422' or
protocol = 'E2597' or
protocol = 'E3598' or
protocol = '9130' or
protocol = 'S9504' or
protocol = '9431' or
protocol = '9534' or
protocol = '30105' or
protocol = '30106' or
protocol = '30407' or
protocol = '39801' or
protocol = 'S9019' or
protocol = '30605' or 
protocol = '9734' or
protocol = '902451';

*impute missing histology with 99;
if histology = .
then histology = 99;

*impute missing initial stage with 3.3;
if missing(stage_initial)
then stage_initial = 3.3; 

* sclc stage should be missing, due to NSCLC stage;
sclc_stage = .;

* group1;
subgroup = 1;

* histology and subgroup may have conflicting information,;
* including histology indicating SCLC for NSCLC trials or histology indicating NSCLC for SCLC trials. ;
if not (histology = 1 and (subgroup = 1 or subgroup = 2));
if not ((histology = 3 or histology = 4 or histology = 5 or histology = 6 or histology = 7 or histology = 8 or histology = 99) and (subgroup = 3 or subgroup = 4));

* exclude ps = 3;
if ps = 0 or ps = 1 or ps = 2;

*indicator = 1 if NSCLC;
if subgroup = 1 or subgroup = 2
then indicator = 1;

*indicator = 0 if SCLC;
if subgroup = 3 or subgroup = 4
then indicator = 0;

* Early Stage;
Disease = 0;
run;

* NSCLC Stage IV;
data group2;
set mydata;
* select trials in NSCLC Stage IV;
if protocol = '30203' or 
protocol = '30303' or
protocol = '30801' or
protocol = '952452' or
protocol = 'E1594' or
protocol = 'E1599' or
protocol = 'E4599' or
protocol = 'N0528' or
protocol = 'N0821' or
protocol = 'N9921' or
protocol = 'S0003' or
protocol = 'S0339' or
protocol = 'S0342' or
protocol = 'S0536' or
protocol = 'S9308' or
protocol = 'S9509' or
protocol = 'S9806' or
protocol = '9532' or 
protocol = '9730' or
protocol = '30402' or
protocol = '30406' or
protocol = '30607' or
protocol = '39809' or
protocol = '922453' or
protocol = '932451' or
protocol = '982452' or
protocol = '982453' or
protocol = 'E3503' or
protocol = 'N0026' or
protocol = 'S0027' or
protocol = 'S0126'or
protocol = 'S0341' or 
protocol = '9132' or
protocol = '892451'or
protocol = 'N0022' or
protocol = 'N0222';

*impute missing histology with 99;
if histology = .
then histology = 99;

*impute missing initial stage with 4.1;
if missing(stage_initial)
then stage_initial = 4.1; 

* sclc stage should be missing, due to NSCLC stage;
sclc_stage = .;

* group2;
subgroup = 2;

* histology and subgroup may have conflicting information,;
* including histology indicating SCLC for NSCLC trials or histology indicating NSCLC for SCLC trials. ;
if not (histology = 1 and (subgroup = 1 or subgroup = 2));
if not ((histology = 3 or histology = 4 or histology = 5 or histology = 6 or histology = 7 or histology = 8 or histology = 99) and (subgroup = 3 or subgroup = 4));

* exclude ps = 3;
if ps = 0 or ps = 1 or ps = 2;

*indicator = 1 if NSCLC;
if subgroup = 1 or subgroup = 2
then indicator = 1;

*indicator = 0 if SCLC;
if subgroup = 3 or subgroup = 4
then indicator = 0;

* Advanced Stage;
Disease = 1;
run;

* SCLC extensive;
data group5;
set mydata;
* select trials in SCLC extensive;
if protocol = '922051' or
protocol = '932051' or
protocol = '932053' or
protocol = '9033' or
protocol = '9430' or
protocol = '9732' or
protocol = '30103' or
protocol = '30104' or
protocol = '30306' or
protocol = '30504' or
protocol = '892051' or
protocol = '912052' or
protocol = '952052' or
protocol = '972052' or
protocol = '982052' or
protocol = 'N0027' or
protocol = 'N0423' or
protocol = 'N0621' or
protocol = 'S0119' or
protocol = 'S0124' or
protocol = 'S0435' or
protocol = 'S9705' or
protocol = 'S9718' or
protocol = 'S9914' or
protocol = 'E1500' or
protocol = 'E3501' or
protocol = 'E5501' or
protocol = 'E7593' or
protocol = 'N0923'; 
*impute missing histology with 1;
if histology = .
then histology = 1;

*initial stage should be missing;
if not missing(stage_initial)
then stage_initial = .;

*sclc stage = 2 due to sclc extensive;
sclc_stage = 2;
stage_initial = sclc_stage;

* group 5;
subgroup = 4;

* histology and subgroup may have conflicting information,;
* including histology indicating SCLC for NSCLC trials or histology indicating NSCLC for SCLC trials;
if not (histology = 1 and (subgroup = 1 or subgroup = 2));
if not ((histology = 3 or histology = 4 or histology = 5 or histology = 6 or histology = 7 or histology = 8 or histology = 99) and (subgroup = 3 or subgroup = 4));
* exclude ps = 3;
if ps = 0 or ps = 1 or ps = 2;
*indicator = 1 if NSCLC;
if subgroup = 1 or subgroup = 2
then indicator = 1;
*indicator = 0 if SCLC;
if subgroup = 3 or subgroup = 4
then indicator = 0;
* Advanced Stage;
Disease = 1;
run;

*group4: SCLC limited;
data group4;
set mydata;
* select trials in SCLC limited;
if protocol = '9235' or 
protocol = '9236' or
protocol = '30002' or
protocol = '30206' or
protocol = '39808' or
protocol = '892052' or
protocol = '952053' or
protocol = '0239' or
protocol = 'E2596' or
protocol = 'N9923' or
protocol = 'S0222' or
protocol = 'S9229' or
protocol = 'S9713';
*impute missing histology with 1;
if histology = .
then histology = 1;
*initial stage should be missing;
if not missing(stage_initial)
then stage_initial = .;
*sclc stage = 1 due to sclc limited;
sclc_stage = 1;
stage_initial = sclc_stage;
* group4;
subgroup = 3;
* histology and subgroup may have conflicting information,;
* including histology indicating SCLC for NSCLC trials or histology indicating NSCLC for SCLC trials. ;
if not (histology = 1 and (subgroup = 1 or subgroup = 2));
if not ((histology = 3 or histology = 4 or histology = 5 or histology = 6 or histology = 7 or histology = 8 or histology = 99) and (subgroup = 3 or subgroup = 4));
* exclude ps = 3;
if ps = 0 or ps = 1 or ps = 2;
*indicator = 1 if NSCLC;
if subgroup = 1 or subgroup = 2
then indicator = 1;
*indicator = 0 if SCLC;
if subgroup = 3 or subgroup = 4
then indicator = 0;
* Early Stage;
Disease = 0;
run;

*NSCLC;
data group12;
set group1 group2;
run;

*SCLC;
data group45;
set group4 group5;
stage_initial = sclc_stage;
run;

*NSCLC + SCLC;
data group1245;
set group12 group45;
run;


*weight loss * subgroup table;
proc freq data=group1245;
format wgt_losspct wgt_losspct.;
table subgroup*wgt_losspct/nocol nopercent;
run;
*/

*read in cleaned_patient_5groups.csv;
*generated from R;
*10128 observations 11 variables;

%let dir = \\tsclient\yingzhous files\MS Thesis Edit 3\;

proc import datafile = "&dir.cleaned_patient_5groups.csv" out = mydata dbms = csv replace;
run;


data group1 group2 group4 group5 group12 group45 group1245;
set mydata;
if subgroup = 1
then output group1;
if subgroup = 2
then output group2;
if subgroup = 3
then output group4;
if subgroup = 4
then output group5;
if subgroup = 1 or subgroup = 2
then output group12;
if subgroup = 3 or subgroup = 4
then output group45;
output group1245;
run;

* No weight loss;
* subgroup = 1;
data group11;
set group1;
where wgt_losspct = 1;
run;

* weight loss;
* subgroup = 1;
data group12;
set group1;
where wgt_losspct = 2;
run;

* No weight loss;
* subgroup = 2;
data group21;
set group2;
where wgt_losspct = 1;
run;

* weight loss;
* subgroup = 2;
data group22;
set group2;
where wgt_losspct = 2;
run;

* No weight loss;
* subgroup = 3;
data group41;
set group4;
where wgt_losspct = 1;
run;

* weight loss;
* subgroup = 3;
data group42;
set group4;
where wgt_losspct = 2;
run;

* No weight loss;
* subgroup = 4;
data group51;
set group5;
where wgt_losspct = 1;
run;

* weight loss;
* subgroup = 4;
data group52;
set group5;
where wgt_losspct = 2;
run;





*Kaplan-Meier curve;
*NSCLC;
*Median Survival Time;
data NSCLC;
set mydata;
if subgroup = 1 or subgroup = 2;
time = time *12;
output NSCLC;
run;

ods pdf file="&dir.Figure 3A org.pdf";

goptions htext = 2 ftext = "Times New Roman" hsize = 22cm vsize = 16cm;

ods trace on;
ods output CensoredSummary = _censorsum
Means = _mean
Quartiles = _quartiles;


proc lifetest data =  NSCLC atrisk plots=survival(nocensor atrisk) outs = output12;
format wgt_losspct wgt_losspct. bmi bmi.;
strata wgt_losspct bmi;
time time * new_censor (0);
run;
ods output close;
ods trace off;
ods pdf close;

*Kaplan-Meier curve;
*SCLC;
*Median Survival Time;
data SCLC;
set mydata;
if subgroup = 3 or subgroup = 4;
time = time *12;
output SCLC;
run;

ods pdf file="&dir.Figure 3B org.pdf";

goptions htext = 2 ftext = "Times New Roman" hsize = 22cm vsize = 16cm;

ods trace on;
ods output CensoredSummary = _censorsum
Means = _mean
Quartiles = _quartiles;


proc lifetest data =  SCLC atrisk plots=survival(nocensor atrisk) outs = output34;
format wgt_losspct wgt_losspct. bmi bmi.;
strata wgt_losspct bmi;
time time * new_censor (0);
run;
ods output close;
ods trace off;
ods pdf close;


*Kaplan Meier Curves;
%macro KM(d, o, filepath);
ods pdf file=&filepath.;

goptions htext = 2 ftext = "Times New Roman" hsize = 22cm vsize = 16cm;


proc lifetest data = &d. atrisk plots=survival(nocensor atrisk) outs = &o.;
strata grade;
time time * new_censor (0);
run;

ods pdf close;
%mend KM;

*check non-linearity and association;
%macro R(d, filepath);
ods pdf file= &filepath.;
%include  "&dir.RCS_Reg.sas"/ nosource;
goptions htext = 2 ftext = "Times New Roman" hsize = 22cm vsize = 16cm;
%RCS_Reg(INFILE = &d.,
         MAIN_SPLINE_VAR = bmi,
         AVK_MSV = 0,
         KNOTS_MSV = 5 35 65 95,
         TYP_REG = cox,
         DEP_VAR = new_censor,
         SURV_TIME_VAR = time,
         EXP_BETA = 0,
         PRINT_OR_HR = 0,
         NO_GRAPH = 0,
         Y_REF_LINE = 1,
		 no_title = 1
);
ods pdf close;

%mend R;

%R(group11,  "&dir.Figure 4A org.pdf")
%R(group12,  "&dir.Figure 4B org.pdf")
%R(group21,  "&dir.Figure 4C org.pdf")
%R(group22,  "&dir.Figure 4D org.pdf")

%R(group41,  "&dir.Figure 5A org.pdf")
%R(group42,  "&dir.Figure 5B org.pdf")
%R(group51,  "&dir.Figure 5C org.pdf")
%R(group52,  "&dir.Figure 5D org.pdf")

* NSCLC grade;
data NSCLC_grade;
set NSCLC;
if bmi >= 22 and wgt_losspct = 1
then grade = '1';
if bmi < 22 and wgt_losspct = 1
then grade = '2';
if bmi >= 22 and wgt_losspct = 2
then grade = '3';
if bmi < 22 and wgt_losspct = 2
then grade = '4';
run;


* SCLC grade;
data SCLC_grade;
set SCLC;
if bmi >= 25 and wgt_losspct = 1
then grade = '1';
else if bmi < 20 and wgt_losspct = 2
then grade = '3';
else grade = '2';
run;

%KM(NSCLC_grade, outputGrade12, "&dir.Figure 3A.pdf")
%KM(SCLC_grade, outputGrade34, "&dir.Figure 3B.pdf")

*Multivariable Piecewise Cox Proportional Hazards Model for Lung Cancer Patient Cohort;
data mydata;
set mydata;
if subgroup = 1 or subgroup = 3
then Disease = 0;
else Disease = 1;
run;

ods pdf file = "&dir.phreg.pdf";
proc phreg data = mydata;
format disease disease. gender gender. race race. histology histology. ps ps. wgt_losspct wgt_losspct. age age. bmi bmi.;
class protocol gender (param = ref order = internal ref = 'male')
race(param = ref order = internal ref = 'other')
ps(param = ref order = internal ref = 'Fully active')
wgt_losspct(param = ref order = internal ref = 'Weight loss  <= 5 %')
disease(param = ref order = internal ref = 'Early' ) 
histology(param = ref order = internal ref = 'other') 
age(param = ref order = internal ref = 'age <= 60') 
bmi(param = ref order = internal ref = 'BMI < 20') ;
model time * new_censor (0) =  gender race ps wgt_losspct disease histology age bmi/ties=efron rl=wald type3(wald);

random protocol;

hAZardratio age /diff=ref CL=both ;
hAZardratio gender /diff=ref CL=both ;
hAZardratio bmi /diff=ref CL=both ;
hAZardratio race /diff=ref CL=both ;
hAZardratio ps /diff=ref CL=both ;
hAZardratio wgt_losspct /diff=ref CL=both ;
hAZardratio histology /diff=ref CL=both ;
hAZardratio disease /diff=ref CL=both ;
*contrast;
*race;
estimate 'Black or African American vs White groups' race  1 -1 / cl e exp;
contrast 'Black or African American vs White groups' race  1 -1 /e;

*ps;
estimate 'Fully active vs Ambulatory groups' ps  1 -1 / cl e exp;
contrast 'Fully active vs Ambulatory groups' ps  1 -1 /e;

*histology;
estimate 'SCLC vs NSCLC groups' histology  1 -1 -1 / cl e exp;
contrast 'SCLC vs NSCLC groups' histology  1 -1 -1 / e;
estimate 'Adenocarcinoma vs Squamous groups' histology  0 1 -1 /cl e exp;
contrast 'Adenocarcinoma vs Squamous groups' histology  0 1 -1 /e;


* bmi;
estimate '22<=BMI<25 vs 20<=BMI<22 groups' bmi -2 1 0 0 / cl e exp;
contrast '22<=BMI<25 vs 20<=BMI<22 groups' bmi -2 1 0 0 /e;
estimate '25<=BMI<28 vs 20<=BMI<22 groups' bmi -3 0 1 0  / cl e exp;
contrast '25<=BMI<28 vs 20<=BMI<22 groups' bmi -3 0 1 0  /e;
estimate 'BMI>=28    vs 20<=BMI<22 groups' bmi -4 0 0 1   / cl e exp;
contrast 'BMI>=28    vs 20<=BMI<22 groups' bmi -4 0 0 1   /e;

estimate 'Age 60-70 vs Age > 70' age -2 1    / cl e exp;
contrast 'Age 60-70 vs Age > 70' age -2 1    /e;
run;
ods pdf close;

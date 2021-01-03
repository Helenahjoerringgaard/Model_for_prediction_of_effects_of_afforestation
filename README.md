# Model_for_prediction_of_effects_of_afforestation
Numerical Model for Prediction of the Effect of Afforestation in Gistrup, Denmark

This model predicts nitrate concentrations throughout the limestone layer at an afforestation site in Gistrup, Northern Jutland, Denmark. Also, the model predicts groundwater recharge and nitrate leaching. The model investigates three scenarios for the project location; continuing arable land, grass field or afforestation. Furthermore, afforestation is examined as either an coniferous or decidious forest. The model includes the growth of the forest until canopy closing after 20 years. 

All files needs to be downloaded, and the .mat files should be imported to Matlab before running the script. 
rain_input.mat is created in the first two sections of the script, but these two sections cannot be run since the excel sheet with raw rain data is not uploaded to GitHub. This is because the file is too big. 
Variable ending "start_condition" is initial values from running the model as a grass field for 10 years from 2010-2020.  

Extrapolation of reference evapotranspiration and adding crop coefficient is done in excel sheets, as is the calulation of leaf area index for a growing forest in the excel sheet "LAI".
"Nitratkoncentrationer" is the measured nitrate concentration at the project location. 

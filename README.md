# radial-time-lapse
MATLAB code to generate radial time lapses similar to the award-winning Gallery of Fluid Motion poster https://doi.org/10.1103/APS.DFD.2021.GFM.P0037

The code is run through main_radialTimeLapse.m, using the functions createRadialTimeLapse.m and createRadialTimeLapseVideo.m.
main_radialTimeLapse.m provides information on how to run the code and parameters that can be adjusted.

To create a radial timelapse, adjacent sectors of consecutive images are combined to create a composite image.
Different time-angle relationships are possible such as linear, exponential, logarithmic, etc. to slow-down or accelerate time in the timelapse image.

Cite this: Lilin, Paul, and Irmgard Bischofberger. "Shattered to pieces: Cracks in drying drops." Physical Review Fluids 7.11 (2022): 110505.

# ISLET: Individual-Specific ceLl typE referencing Tool 


-------------------
<img align="left" src="vignettes/islet_hex_2.png" width="156" height="180"> We developed a method called `ISLET` (Individual-Specific ceLl typE referencing Tool), to deconvolute mixture samples and obtain the individual-specific and cell-type-specific reference panels. `ISLET` can leverage on multiple observations or temporal measurements of the same subject. `ISLET` adopted a more reasonable assumption that repeated samples from the same subject would share the same reference panel. This unknown panel, treated as missing values, are estimated by an iterative Expectation--Maximization (EM) algorithm in mixed-effect regression framework, when combining all samples from all subjects together. This is the first statistical framework to estimate the subject-level cell-type-specific reference panel, for repeated measures. Our modeling can effectively borrow information across samples within the same subject.


#### `ISLET` is currently on Bioconductor at <https://bioconductor.org/packages/ISLET/>.

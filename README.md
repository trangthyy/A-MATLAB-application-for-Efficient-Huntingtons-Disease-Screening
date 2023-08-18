# A-MATLAB-program-for-Hungtingtons-Disease-Screening

## Introduction
Huntington’s Disease (HD) is a neurodegenerative disorder caused by the dysfunction of the basal ganglia in the human brain. It involves the HTT gene encoding for the Huntingtin protein. Patients who have more than 40 **consecutive** CAG repeats on the HTT gene typically develop HD in their lives while those who have less than 35 repeats do not [1]. Meanwhile, individuals who have 36 to 39 repeats may or may not develop HD throughout their lives [1].

To aid in the early detection of the disease by genetic analysis, we provide a comprehensive MATLAB application (_mainscript_) capable of screening HD that encompasses three functions:
1. Screen Multiple Sequences & Create Database
2. Append New Profile
3. Visualize Individual Data

We also developed two scripts: _randomCAG_ to randomly create large genetic datasets for HD due to the lack of an accessible data source (based on the Reference gene obtained from Ensembl https://asia.ensembl.org/Homo_sapiens/Transcript/Summary?g=ENSG00000197386;r=4:3074681-3243957;t=ENST00000355072) and _time_analysis_ to analyze the time consumed by the program for large-scale data screening (Screen Multiple Sequences & Create Database function).
By providing the HTT gene analysis, our program aims to automate and reduce the cost of the HD screening service.

## _mainscript_
The _mainscript_ has three functions and their usage is described.
### Screen Multiple Sequences & Create Database

![Figure 2 (instruction)](https://github.com/trangthyy/A-MATLAB-application-for-Efficient-Huntingtons-Disease-Screening/assets/139542244/56e3a1c8-a04b-4c69-8ff9-6609933371f1)

To screen for HD in a large set of genetic sequences and record data in a database, you can choose the ‘Screen Multiple Sequences and Create Database’ function (**Fig a**). When running _mainscript_ in MATLAB, select the function, then the program requires you to select a folder (**Fig b**) of genetic sequences saved as **text files**. The program then asks you to name the database. Subsequently, the program will analyze and save the results in an Excel database accordingly, as shown in **Fig c**. Note that the genetic sequences used in this project were generated from _randomCAG_ script as described above.

The Excel database has five columns, representing five outputs/results for each genetic sequence:
1. ID
2. Diagnosis
3. CAG repeats
4. Cut sequence
5. Raw data

The program can detect non-gene files and save the ID as 'error' and Diagnosis as 'File error'. 

In addition, each genetic sequence will be visualized in a comprehensive figure that will be saved in the same folder.

![randomSeq2](https://github.com/trangthyy/A-MATLAB-application-for-Efficient-Huntingtons-Disease-Screening/assets/139542244/fe28d0df-c77a-4ec5-9f9f-d7e57290ec7e)

The Reference gene was used as an example for visualization. It was found to have a maximum of 19 consecutive CAG repeats (bar graph, top left) located at the beginning of the HTT gene (sequence heatmap, bottom). Note that there are around 150 CAG repeats in total but only a maximum of 19 consecutive ones (codon frequency heatmap, top right).

Other sequences will be visualized in the same graphs, but the number of codons and their positions will vary.

**NOTE**:
1. Genetic sequences have to be saved in text file format.
2. Due to the large number of data, figures will not be displayed in the Screen Multiple Sequences & Create Database function.

### Append New Profile

![Figure 3 (instruction)](https://github.com/trangthyy/A-MATLAB-application-for-Efficient-Huntingtons-Disease-Screening/assets/139542244/a474c1f9-4f69-4d14-a743-4f4a4c89e55f)

Next, you can use the function 'Append New Profile' to append a single new profile to the created database. After selecting the function, the program then asks you to input the new ID. Next, you can either:
* Paste a sequence
* Import a text file

Subsequently, a new visualizing figure will also be created, displayed, and saved.

### Visualize Individual Data

![Figure 4 (instruction)](https://github.com/trangthyy/A-MATLAB-application-for-Efficient-Huntingtons-Disease-Screening/assets/139542244/ccc1d176-d2bf-46f9-a1bc-845b285bc6e3)

Finally, the program offers the ‘Visualize Individual Data’ function to analyze a specific profile within an existing database. After choosing the ‘Visualize Individual Data’ function, you can select a database, write the ID of the desired sequence, and the visualization graphs will be displayed.

## _randomCAG_
Due to a lack of a public genetic database for HD, we created randomCAG script to generate 10,000 sequences for efficiency assessment using the raw Reference gene as the template (obtained from Ensembl https://asia.ensembl.org/Homo_sapiens/Transcript/Summary?g=ENSG00000197386;r=4:3074681-3243957;t=ENST00000355072). The position and length of CAG repeats were determined randomly within appropriate ranges.

## _time_analysis_
To assess the efficiency of large-scale data screening, we created _time_analysis_ to screen folders of 1,000 to 10,000 genetic sequences, with 1,000 file intervals. The script consists only of the codes from the Screen Multiple Sequences & Create Database function and additional codes to measure processing time.

![time analysis](https://github.com/trangthyy/A-MATLAB-application-for-Efficient-Huntingtons-Disease-Screening/assets/139542244/2437759f-a9bb-44be-bc5f-f938dda77148)

The average processing time was 2.2 seconds/file. The modest increment in processing time demonstrates the program's consistent performance in handling large volumes without substantial slowdowns.

The program run and measurement were performed on an x64-based PC (Model: SYS-5039A-I), Intel® Xeon® W-2255 CPU @ 3.70GHz.

## References
[1] Huntington disease. MedlinePlus Genetics. https://medlineplus.gov/‌genetics/condition/‌ h‌untington-disease/, last accessed 2023/07/08.

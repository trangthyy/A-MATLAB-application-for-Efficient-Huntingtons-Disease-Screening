# A-MATLAB-program-for-Hungtingtons-Disease-Screening

## Introduction
Huntington’s Disease (HD) is a neurodegenerative disorder caused by the dysfunction of the basal ganglia in the human brain. It involves the HTT gene encoding for the Huntingtin protein. Patients who have more than 40 **consecutive** CAG repeats on the HTT gene typically develop HD in their lives while those who have less than 35 repeats do not [1]. Meanwhile, individuals who have 36 to 39 repeats may or may not develop HD throughout their lives [1].

To aid in the early detection of the disease by genetic analysis, we provide a comprehensive MATLAB application (_mainscript_) capable of screening HD that encompasses:
1. Screen Multiple Sequences & Create Database
2. Append New Profile
3. Visualize Individual Data

We also developed two scripts: _randomCAG_ to create large genetic datasets for HD (based on the Reference gene obtained from Ensembl https://asia.ensembl.org/Homo_sapiens/Transcript/Summary?g=ENSG00000197386;r=4:3074681-3243957;t=ENST00000355072) and _time_analysis_ to analyze the time consumed by the program for large-scale data screening.
By providing the HTT gene analysis, our program aids in cutting the cost of the HD screening service.

## _mainscript_
The _mainscript_ has three functions and their usage is described.
### Screen Multiple Sequences & Create Database
![image](https://github.com/trangthyy/A-MATLAB-program-for-Hungtingtons-Disease-Screening/assets/139542244/b28e7a60-db01-432a-bcec-40aa1332733d)
When starting the _mainscript_ in MATLAB, you can choose ‘Screen Multiple Sequences and Create Database’ to screen HD (**Fig a**). This function requires you to select a folder (**Fig b**) of genetic sequences saved as **text files**. The program then asks you to name the database to be created. Subsequently, the program will analyze and save the results in an Excel database accordingly, as shown in **Fig c**. 

The Excel database has five columns, representing five outputs/results for each genetic sequence:
1. ID
2. Diagnosis
3. CAG repeats
4. Cut sequence
5. Raw data

The program can detect non-gene files and save the ID as 'error' and Diagnosis as 'File error'. 

In addition, each genetic sequence will be visualized in a comprehensive figure that will be saved in the same folder.
![image](https://github.com/trangthyy/A-MATLAB-program-for-Hungtingtons-Disease-Screening/assets/139542244/d2461a05-6ebe-4b64-821c-08164429b59e)
The Reference gene was used as an example for visualization. It was found to have a maximum of 19 consecutive CAG repeats (bar graph, top left) located at the beginning of the HTT gene (sequence heatmap, bottom). Note that there are around 150 CAG repeats in total but only 19 consecutive ones (codon frequency heatmap, top right).

Other sequences will be visualized in the same graphs, but the number of codons and their positions will vary.

**NOTE**:
1. Genetic sequences have to be saved in text file format.
2. Due to the large number of data, figures will not be displayed in the Screen Multiple Sequences & Create Database function.

### Append New Profile
![image](https://github.com/trangthyy/A-MATLAB-program-for-Hungtingtons-Disease-Screening/assets/139542244/1860e11c-191d-45c9-bdbf-924ae3c4d9c2)
Next, you can use the function 'Append New Profile' to append a single new profile to the created database. You can either:
* Paste a sequence
* Import a text file

Subsequently, a new visualizing figure will also be created, displayed, and saved.

### Visualize Individual Data
![image](https://github.com/trangthyy/A-MATLAB-program-for-Hungtingtons-Disease-Screening/assets/139542244/6d208736-0001-460d-aaaa-5feeb3fa9817)
Finally, the program offers the ‘Visualize Individual Data’ function to analyze a specific profile within an existing database. After choosing the ‘Visualize Individual Data’ function, you can select a database, write the ID of the desired sequence, and the visualization graphs will be displayed.

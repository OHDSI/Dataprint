# OHDSI Dataprint
A Novel Visualization Tool for Database Comparison

## Background
OHDSI is a distributed data sharing and research network which aggregates large, international clinical databases to aid  multisite observational studies for generating evidence that improves health care. The databases available in the network
differ in terms of patient representation, data capture process, and availability of longitudinal information. These differences give each database a unique set of characteristics or fingerprints, which we call a “dataprint.” Effective use of a data network requires researchers to understand the dataprint of available databases, specifically the heterogeneity of the patient populations, which can inform decisions about which dataset is best suited to inform a research topic. Visualizations provide a facile method for capturing data heterogeneity in comparison to numerical tables. Dataprints were developed as a novel visualization to provide transparenty to the heterogeneity across datasources in the network.

## Requirements
The Dataprint package will generate a JSON file containing all of the information required to generate the visualization.  This requires that your data has been converted to the OMOP Common Data Model format version 5+.

## Running Dataprint
```{r}
# provide connection details to your CDM
connectionDetails <- DatabaseConnector::createConnectionDetails(
	dbms ="postgresql",
	server = "your_server",
	user = "username",
	password = "strong_password"
)

# generate the Dataprint data file
dataprint <- Dataprint::generateDataprint(
	connectionDetails = connectionDetails, 
	cdmQualifier = "public.cdm", 
	caption = "name of this data source to appear in the visualization", 
	dbms = "postgresql"
)

# save your results
jsonlite::write_json(dataprint, "test.json")
```
## Generating the Visualization
The Dataprint R package contains files in the /extras/web folder that create a single datasource or network Dataprint visualization from a set of JSON files created by the Dataprint::generateDataprint method.  The following steps are required after generating the JSON file to render the visualization.

1. Host the contents of the /extras/web folder on a web server.
2. Place your JSON files in the data folder subdirectory of where you are hosting the /extras/web folder.
3. Edit the array found in the index.html file to include the desired list of datasource JSON files that you have placed in the data directory.

```{javascript}
		var databases = [
			"test.json"
		]; // add more here
```

### References

[Dataprint Poster](http://www.ohdsi.org/web/wiki/lib/exe/fetch.php?media=resources:abstract_dataprint_ohdsi_defalco.pdf)

Huser, V, DeFalco, FJ, Schuemie, M, Ryan, PB, Shang, N, Velez, M, et al. Multisite evaluation of a data quality tool
for patient-level clinical datasets. eGEMs. 2016;4(1).

Kahn, MG, Brown, JS, Chun, AT, Davidson, BN, Meeker, D, Ryan, PB, et al. Transparent reporting of data quality
in distributed data networks. eGEMs. 2015; 3(1):1052.


#' Generates a Dataprint from a CDM v5 database
#' 
#' @param connectionDetails A connectionDetails object created by the DatabaseConnector package.
#' @param cdmQualifier The table qualifer for CDM tables (ie, NHANES.dbo)
#' @param dbms The SqlRender supported DBMS platform (ie, postgresql, pdw)
#' @export

generateDataprint <- function(connectionDetails, cdmQualifier, caption, dbms) {
	dataprint <- {}
	dataprint$caption <- jsonlite::unbox(caption);
	
	queryTotalPeople <- SqlRender::loadRenderTranslateSql("getDistinctPersonCount.sql", packageName = "Dataprint", dbms=dbms)

	connection <- DatabaseConnector::connect(connectionDetails)
	queryTotalPeople <- SqlRender::renderSql(queryTotalPeople, cdmQualifier=cdmQualifier)$sql
	totalPeople <- DatabaseConnector::querySql(connection, queryTotalPeople)
	dataprint$totalPeople <- jsonlite::unbox(totalPeople$PERSONCOUNT)
	
	peopleMinutia <- generateMinutia(cdmQualifier,connection, "observation_period", "observation_period_start_date", "Observation Periods", dbms)
	conditionMinutia <- generateMinutia(cdmQualifier,connection, "condition_occurrence", "condition_start_date", "Conditions", dbms)
	drugexpMinutia <- generateMinutia(cdmQualifier,connection, "drug_exposure", "drug_exposure_start_date", "Drug Exposures", dbms)
	procedureMinutia <- generateMinutia(cdmQualifier,connection, "procedure_occurrence", "procedure_date", "Procedures", dbms)
	deathMinutia <- generateMinutia(cdmQualifier,connection, "death", "death_date", "Deaths", dbms)
	deviceexpMinutia <- generateMinutia(cdmQualifier,connection, "device_exposure", "device_exposure_start_date", "Device Exposures", dbms)
	measurementMinutia <- generateMinutia(cdmQualifier,connection, "measurement", "measurement_date", "Measurements", dbms)
	noteMinutia <- generateMinutia(cdmQualifier, connection, "note", "note_date", "Notes", dbms)
	observationMinutia <- generateMinutia(cdmQualifier,connection, "observation", "observation_date", "Observations", dbms)
	visitMinutia <- generateMinutia(cdmQualifier,connection, "visit_occurrence", "visit_start_date", "Visit Occurrence", dbms)
	
	dataprint$minutiae <- list(peopleMinutia, conditionMinutia, drugexpMinutia, procedureMinutia,deathMinutia, deviceexpMinutia,measurementMinutia,
														 noteMinutia, observationMinutia, visitMinutia)
	dataprint
}
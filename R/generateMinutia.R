generateMinutia <- function(cdmQualifier, connection, tableName, dateColumnName, caption, dbms) {
	print(paste0("processing ", tableName))
	queryDomainStratification <- SqlRender::loadRenderTranslateSql("getStratifiedDomainData.sql", "Dataprint", dbms=dbms)
	queryDistinctPeople <- SqlRender::loadRenderTranslateSql("getDomainDistinctPersonCount.sql", "Dataprint", dbms=dbms)
	
	sqlDistinctPeople <- SqlRender::renderSql(queryDistinctPeople, cdmQualifier=cdmQualifier, tableName=tableName)
	resultDistinctPeople <- DatabaseConnector::querySql(connection, sqlDistinctPeople$sql)
	
	query <- SqlRender::renderSql(queryDomainStratification, cdmQualifier=cdmQualifier, tableName=tableName, dateColumnName=dateColumnName)
	results <- DatabaseConnector::querySql(connection, query$sql)
	
	dataStats <- {}
	dataStats$sd <- jsonlite::unbox(sd(results$AGE))
	dataStats$median <- jsonlite::unbox(median(results$AGE))
	dataStats$mean <- jsonlite::unbox(mean(results$AGE))
	
	results <- results[order(results$AGE),]
	if (sum(results$AGE) == 0) {
		dataStats$quantiles <- c();
	} else {
		quantResults <- filter(results, results$AGE <=100)
		quantResults <- quantResults %>%
			group_by(AGE) %>%
			summarize(recordCount=sum(RECORD_COUNT)) %>%
			arrange(AGE)
		
		quantResults$cumsum <- cumsum(quantResults$recordCount)
		quantResults$cd <- quantResults$cumsum/sum(quantResults$recordCount)
		quantiles <- c(
			quantResults$AGE[which.min(abs(quantResults$cd-0.0))],
			quantResults$AGE[which.min(abs(quantResults$cd-0.25))],
			quantResults$AGE[which.min(abs(quantResults$cd-0.50))],
			quantResults$AGE[which.min(abs(quantResults$cd-0.75))],
			quantResults$AGE[which.min(abs(quantResults$cd-1.0))]
		)
		dataStats$quantiles <- quantiles
	}
	
	results$ageBucket <-cut(results$AGE, breaks=seq(0,100, by=5), labels=seq(5,100, by=5), include.lowest = T)
	results$ageBucket <- as.numeric(as.character(results$ageBucket))
	summary <- results %>%
		group_by(ageBucket,GENDER_CONCEPT_ID) %>%
		summarize(recordCount=sum(RECORD_COUNT))
	
	complete <- expand.grid(ageBucket=seq(0,100, by=5), GENDER_CONCEPT_ID=c(8507,8532))
	full <- merge(complete, summary, all.x = T)
	full[is.na(full)] <- 0
	
	maleData <- full[full$GENDER_CONCEPT_ID==8507,c(1,3)]
	femaleData <- full[full$GENDER_CONCEPT_ID==8532,c(1,3)]
	
	male <- list(data = maleData, caption=jsonlite::unbox("Male"))
	female <- list(data = femaleData, caption=jsonlite::unbox("Female"))
	minutia <- {}
	
	minutia$distinctPeople <- jsonlite::unbox(resultDistinctPeople$PERSONCOUNT)
	
	minutia$stats <- dataStats
	minutia$caption <- jsonlite::unbox(caption)
	minutia$series <- list(male,female)
	minutia
}
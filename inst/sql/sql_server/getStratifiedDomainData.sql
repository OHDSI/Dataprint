	select gender_concept_id, year(@dateColumnName) - year_of_birth age, count(*) record_count
	from @cdmQualifier.person p
	join @cdmQualifier.@tableName on p.person_id = @cdmQualifier.@tableName.person_id
	group by gender_concept_id, year(@dateColumnName) - year_of_birth
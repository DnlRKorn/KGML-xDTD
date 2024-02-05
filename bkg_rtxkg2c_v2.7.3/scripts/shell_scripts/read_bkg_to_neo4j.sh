#!/usr/bin/env bash
# Import TSV files into Neo4j

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]
then
    echo Usage: "$0 <database-name>=graph.db <path_neo4j.conf>=neo4j.conf <path_tsv_folder>=./rtxkg2c-tsv_for_neo4j/"
    echo Usage Example: "$0 customized_rtxkg2c.db ~/neo4j-community-3.5.26/conf/neo4j.conf ~/kg/rtxkg2c-tsv_for_neo4j/"
	exit
fi

echo "================= reading TSV files into Neo4j =================="
if [[ "${1:-}" == "" ]]
then
	echo "Please specify <database-name> in the first parameter"
	exit
else
	database=$1
fi

if [[ "${2:-}" == "" ]]
then
	echo "Please specify the path of <path_neo4j.conf> in the second parameter"
	exit
else
	neo4j_config=$2 
fi

if [[ "${3:-}" == "" ]]
then
	echo "Please specify the path of <path_tsv_folder> in the third parameter"
	exit
else
	tsv_dir=$3
fi

# change database and database paths to current database and database path in config file
sed -i.bk "s/.*dbms.active_database=.*/dbms.active_database=${database}/" ${neo4j_config}
rm -rf ${neo4j_config}.bk

# stop neo4j
neo4j_command=`echo ${neo4j_config} | sed 's/conf\/neo4j.conf/bin\/neo4j/'`
${neo4j_command} stop

# change the database to write mode
sed -i.temp "s/dbms.read_only=true/dbms.read_only=false/" ${neo4j_config}
rm -rf ${neo4j_config}.temp

# delete the old log file and create a new one
rm -rf ${tsv_dir}/import.report
touch ${tsv_dir}/import.report

# import TSV files into Neo4j as Neo4j
neo4j_admin_command=`echo ${neo4j_config} | sed 's/conf\/neo4j.conf/bin\/neo4j-admin/'`
${neo4j_admin_command} import --nodes "${tsv_dir}/nodes_c_header.tsv,${tsv_dir}/nodes_c.tsv" \
    --relationships "${tsv_dir}/edges_c_header.tsv,${tsv_dir}/edges_c.tsv" \
    --max-memory=20G --multiline-fields=true --delimiter "\t" \
    --array-delimiter="ǂ" --report-file="${tsv_dir}/import.report" \
    --database=${database} --ignore-missing-nodes=true


#!/usr/bin/env python3
## This code is donwloaded from the Github repo (https://github.com/RTXteam/RTX-KG2) and modified to index the version 2.7.3 of RTX-KG2c (Wood et al. 2021 doi: 10.1101/2021.10.17.464747) in neo4j database

import neo4j
import sys, os
neo4j_bolt = os.getenv('neo4j_bolt')
neo4j_username = os.getenv('neo4j_username')
neo4j_password = os.getenv('neo4j_password')

def run_query(query):
    """
    :param query: a cypher statement as a string to run
    """
    # Start a neo4j session, run a query, then close the session
    session = driver.session()
    query = session.run(query)
    session.close()
    return query


def node_labels():
    # Create a list of dictionaries where each key is "labels(n)"
    # and each value is a list containing a node label
    labels = "MATCH (n) RETURN distinct labels(n)"
    query = run_query(labels)
    data = query.data()
    label_list = []
    # Iterate through the list and dicitionaries to create a list
    # of node labels
    for dictionary in data:
        for key in dictionary:
            value = dictionary[key]
            value_string = value[0]
            label_list.append(value_string)
    return label_list


def create_index(label_list, property_name):
    """
    :param label_list: a list of the node labels in Neo4j
    """
    # For every label in the label list, create an index
    # on the given property name
    for label in label_list:
        index_query = "CREATE INDEX ON :`" + label + "` (" + property_name + ")"
        run_query(index_query)


def constraint(label_list):
    """
    :param label_list: a list of the node labels in Neo4j
    """
    # For every label in the label list, create a unique constraint
    # on the node id property
    constraint_query = "CREATE CONSTRAINT ON (n:Base) ASSERT n.id IS UNIQUE"
    run_query(constraint_query)


if __name__ == '__main__':
    neo4j_password = neo4j_password
    neo4j_user = neo4j_username
    bolt = neo4j_bolt
    driver = neo4j.GraphDatabase.driver(bolt, auth=(neo4j_user, neo4j_password))
    node_label_list = node_labels() + ['Base']

    # Create Indexes on Node Properties
    create_index(node_label_list, "category")
    create_index(node_label_list, "name")

    constraint(node_label_list)
    driver.close()

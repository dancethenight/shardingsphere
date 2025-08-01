/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

grammar DMLStatement;

import BaseRule;

insert
    : withClause? INSERT top? INTO? (tableName | rowSetFunction) (AS? alias)? withTableHint?  (insertDefaultValue | insertValuesClause | insertSelectClause | insertExecClause)
    ;

insertDefaultValue
    : columnNames? outputClause? DEFAULT VALUES
    ;

insertValuesClause
    : columnNames? outputClause? VALUES assignmentValues (COMMA_ assignmentValues)*
    ;

insertSelectClause
    : columnNames? outputClause? select
    ;

insertExecClause
    : columnNames? exec
    ;

merge
    : withClause? MERGE top? mergeIntoClause withMergeHint? (AS? alias)? mergeUsingClause? mergeWhenClause* outputClause? optionHint?
    ;

mergeIntoClause
    : INTO? tableReferences
    ;

mergeUsingClause
    : USING tableReferences (AS? alias)? ON expr
    ;

withMergeHint
    : withTableHint (COMMA_? INDEX LP_ indexName (COMMA_ indexName)* RP_ | INDEX EQ_ indexName)?
    ;

mergeWhenClause
    : mergeUpdateClause | mergeDeleteClause | mergeInsertClause
    ;

mergeUpdateClause
    : (WHEN MATCHED | WHEN NOT MATCHED BY SOURCE) (AND expr)? THEN UPDATE setAssignmentsClause
    ;

mergeDeleteClause
    : (WHEN MATCHED | WHEN NOT MATCHED BY SOURCE) (AND expr)? THEN DELETE
    ;

mergeInsertClause
    : WHEN NOT MATCHED (BY TARGET)? (AND expr)? THEN INSERT (insertDefaultValue | insertValuesClause)
    ;

withTableHint
    : WITH? LP_ (tableHintLimited | tableHintExtended) (COMMA_ (tableHintLimited | tableHintExtended))* RP_
    ;

exec
    : (EXEC | EXECUTE) procedureName (expr (COMMA_ expr)*)?
    ;

update
    : withClause? UPDATE top? tableReferences withTableHint? setAssignmentsClause fromClause? outputClause? whereClause? optionHint?
    ;

assignment
    : columnName ((PLUS_ | MINUS_ | ASTERISK_ | SLASH_ | MOD_)? EQ_ | DOT_) assignmentValue
    ;

setAssignmentsClause
    : SET assignment (COMMA_ assignment)*
    ;

assignmentValues
    : LP_ assignmentValue (COMMA_ assignmentValue)* RP_
    | assignmentValue
    | LP_ RP_
    ;

assignmentValue
    : expr | DEFAULT
    ;

delete
    : withClause? DELETE top? (singleTableClause | multipleTablesClause) outputClause? whereClause? optionHint?
    ;

optionHint
    : OPTION queryHint
    ;

singleTableClause
    : FROM? LP_? tableName RP_? (AS? alias)?
    ;

multipleTablesClause
    : multipleTableNames FROM tableReferences | FROM multipleTableNames USING tableReferences
    ;

multipleTableNames
    : tableName DOT_ASTERISK_? (COMMA_ tableName DOT_ASTERISK_?)*
    ;

select
    : aggregationClause
    ;

aggregationClause
    : selectClause ((UNION (ALL)? | EXCEPT | INTERSECT) selectClause)*
    ;

selectClause
    : selectWithClause? SELECT duplicateSpecification? projections intoClause? (fromClause withTempTable? withTableHint?)? whereClause? groupByClause? havingClause? orderByClause? forClause?
    ;

duplicateSpecification
    : ALL | DISTINCT
    ;

projections
    : (projection | top projection?) (COMMA_ projection)*
    ;

projection
    : qualifiedShorthand
    | unqualifiedShorthand
    | (alias EQ_)? (columnName | expr)
    | (columnName | expr) (AS? alias)?
    ;

top
    : TOP LP_? topNum RP_? PERCENT? (WITH TIES)? (ROW_NUMBER LP_ RP_ OVER LP_ orderByClause RP_ (AS? alias)?)?
    ;

topNum
    : numberLiterals | parameterMarker
    ;

unqualifiedShorthand
    : ASTERISK_
    ;

qualifiedShorthand
    : identifier DOT_ASTERISK_
    ;

intoClause
    : INTO tableName
    ;

fromClause
    : FROM tableReferences
    ;

tableReferences
    : tableReference (COMMA_ tableReference)*
    ;

tableReference
    : tableFactor joinedTable*
    ;

tableFactor
    : tableName (FOR PATH)? (AS? alias)? withTableHint? | subquery AS? alias columnNames? | expr (AS? alias)? | xmlMethodCall (AS? alias)? columnNames? | LP_ tableReferences RP_ | pivotTable
    ;

pivotTable
    : pivotClause (AS? alias)?
    ;

pivotClause
    : (tableName | subquery) PIVOT LP_ aggregationFunction FOR columnName IN LP_ pivotValueList RP_ RP_
    | (tableName | subquery) UNPIVOT LP_ columnName FOR columnName IN LP_ pivotValueList RP_ RP_
    | subquery AS? alias PIVOT LP_ aggregationFunction FOR columnName IN LP_ pivotValueList RP_ RP_
    | subquery AS? alias UNPIVOT LP_ columnName FOR columnName IN LP_ pivotValueList RP_ RP_
    ;

pivotValueList
    : pivotValue (COMMA_ pivotValue)*
    ;

pivotValue
    : LBT_ expr RBT_ | expr
    ;

joinedTable
    : NATURAL? ((INNER | CROSS)? joinHint? JOIN) tableFactor joinSpecification?
    | NATURAL? (LEFT | RIGHT | FULL) OUTER? joinHint? JOIN tableFactor joinSpecification?
    | (CROSS | OUTER) APPLY tableFactor joinSpecification?
    ;

joinHint
    : LOOP | HASH | MERGE | REMOTE | REDUCE | REPLICATE | REDISTRIBUTE (LP_ NUMBER_ RP_)?
    ;

joinSpecification
    : ON expr | USING columnNames
    ;

whereClause
    : WHERE expr
    ;

groupByClause
    : GROUP BY orderByItem (COMMA_ orderByItem)* (WITH ROLLUP)?
    ;

havingClause
    : HAVING expr
    ;

subquery
    : LP_ (aggregationClause | merge) RP_
    ;

withTempTable
    : WITH LP_ (columnName dataType) (COMMA_ columnName dataType)* RP_ AS alias
    ;

withClause
    : WITH cteClauseSet
    ;

cteClauseSet
    : cteClause (COMMA_ cteClause)*
    ;

cteClause
    : alias columnNames? AS subquery
    ;

outputClause
    : OUTPUT (outputWithColumns | outputWithAaterisk) (INTO outputTableName columnNames?)?
    ;

outputWithColumns
    : (outputWithColumn | scalarExpression) (COMMA_ (outputWithColumn | scalarExpression))*
    ;

scalarExpression
    : expr (AS? alias)?
    ;

outputWithColumn
    : (INSERTED | DELETED) DOT_ name (AS? alias)?
    ;

outputWithAaterisk
    : (INSERTED | DELETED) DOT_ASTERISK_
    ;

outputTableName
    : tableName
    ;

queryHint
    : (HASH | ORDER) GROUP
    | (CONCAT | HASH | MERGE) UNION
    | (LOOP | MERGE | HASH) JOIN
    | EXPAND VIEWS
    | FAST INT_NUM_
    | FORCE ORDER
    | (FORCE | DISABLE) EXTERNALPUSHDOWN
    | (FORCE | DISABLE) SCALEOUTEXECUTION
    | IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX
    | KEEP PLAN
    | KEEPFIXED PLAN
    | MAX_GRANT_PERCENT EQ_ DECIMAL_NUM_
    | MIN_GRANT_PERCENT EQ_ DECIMAL_NUM_
    | MAXDOP INT_NUM_
    | MAXRECURSION INT_NUM_
    | NO_PERFORMANCE_SPOOL
    | LP_ OPTIMIZE FOR LP_ variableName (UNKNOWN | EQ_ literals)* RP_ RP_
    | OPTIMIZE FOR UNKNOWN
    | PARAMETERIZATION (SIMPLE | FORCED)
    | QUERYTRACEON INT_NUM_
    | RECOMPILE
    | ROBUST PLAN
    | USE HINT LP_ useHitName* RP_
    | USE PLAN NCHAR_TEXT
    ;

useHitName
    : SQ_ ASSUME_JOIN_PREDICATE_DEPENDS_ON_FILTERS SQ_
    | SQ_ ASSUME_MIN_SELECTIVITY_FOR_FILTER_ESTIMATES SQ_
    | SQ_ DISABLE_BATCH_MODE_ADAPTIVE_JOINS SQ_
    | SQ_ DISABLE_BATCH_MODE_MEMORY_GRANT_FEEDBACK SQ_
    | SQ_ DISABLE_DEFERRED_COMPILATION_TV SQ_
    | SQ_ DISABLE_INTERLEAVED_EXECUTION_TVF SQ_
    | SQ_ DISABLE_OPTIMIZED_NESTED_LOOP SQ_
    | SQ_ DISABLE_OPTIMIZER_ROWGOAL SQ_
    | SQ_ DISABLE_PARAMETER_SNIFFING SQ_
    | SQ_ DISABLE_ROW_MODE_MEMORY_GRANT_FEEDBACK SQ_
    | SQ_ DISABLE_TSQL_SCALAR_UDF_INLINING SQ_
    | SQ_ DISALLOW_BATCH_MODE SQ_
    | SQ_ ENABLE_HIST_AMENDMENT_FOR_ASC_KEYS SQ_
    | SQ_ ENABLE_QUERY_OPTIMIZER_HOTFIXES SQ_
    | SQ_ FORCE_DEFAULT_CARDINALITY_ESTIMATION SQ_
    | SQ_ FORCE_LEGACY_CARDINALITY_ESTIMATION SQ_
    | SQ_ QUERY_OPTIMIZER_COMPATIBILITY_LEVEL_n SQ_
    | SQ_ QUERY_PLAN_PROFILE SQ_
    ;

forClause
    : FOR (BROWSE | forXmlClause | forJsonClause)
    ;

forXmlClause
    : XML ((RAW (LP_ stringLiterals RP_)? | AUTO) (commonDirectivesForXml (COMMA_ (XMLDATA | XMLSCHEMA (LP_ stringLiterals RP_)?))? (COMMA_ ELEMENTS (XSINIL | ABSENT)?)?)?
    | EXPLICIT (commonDirectivesForXml (COMMA_ XMLDATA)?)?
    | PATH (LP_ stringLiterals RP_)? (commonDirectivesForXml (COMMA_ ELEMENTS (XSINIL | ABSENT)?)?)?)
    ;

commonDirectivesForXml
    : (COMMA_ BINARY BASE64)? (COMMA_ TYPE)? (COMMA_ ROOT (LP_ stringLiterals RP_)?)?
    ;

forJsonClause
    : JSON ((AUTO | PATH) ((COMMA_ ROOT (LP_ stringLiterals RP_)?)? (COMMA_ INCLUDE_NULL_VALUES)? (COMMA_ WITHOUT_ARRAY_WRAPPER)?)?)
    ;

selectWithClause
    : WITH (xmlNamespacesClause COMMA_?)? cteClauseSet?
    ;

xmlNamespacesClause
    : XMLNAMESPACES LP_ xmlNamespaceDeclarationItem (COMMA_ xmlNamespaceDeclarationItem)* RP_
    ;

xmlNamespaceDeclarationItem
    : xmlNamespaceUri AS xmlNamespacePrefix | xmlDefaultNamespaceDeclarationItem
    ;

xmlNamespaceUri
    : stringLiterals
    ;

xmlNamespacePrefix
    : identifier
    ;

xmlDefaultNamespaceDeclarationItem
    : DEFAULT xmlNamespaceUri
    ;

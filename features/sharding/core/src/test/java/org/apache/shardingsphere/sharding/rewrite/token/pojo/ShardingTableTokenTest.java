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

package org.apache.shardingsphere.sharding.rewrite.token.pojo;

import org.apache.shardingsphere.infra.binder.context.statement.type.dml.SelectStatementContext;
import org.apache.shardingsphere.infra.route.context.RouteMapper;
import org.apache.shardingsphere.infra.route.context.RouteUnit;
import org.apache.shardingsphere.sharding.rule.ShardingRule;
import org.apache.shardingsphere.sql.parser.statement.core.value.identifier.IdentifierValue;
import org.junit.jupiter.api.Test;

import java.util.Collections;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.mockito.Mockito.RETURNS_DEEP_STUBS;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ShardingTableTokenTest {
    
    @Test
    void assertToStringWithActualTableName() {
        assertThat(createTableToken("foo_tbl").toString(mockRouteUnit()), is("foo_tbl_0"));
    }
    
    @Test
    void assertToStringWithOriginalTableName() {
        assertThat(createTableToken("bar_tbl").toString(mockRouteUnit()), is("bar_tbl"));
    }
    
    private ShardingTableToken createTableToken(final String tableName) {
        return new ShardingTableToken(0, 0, new IdentifierValue(tableName), mock(SelectStatementContext.class, RETURNS_DEEP_STUBS), mock(ShardingRule.class));
    }
    
    private RouteUnit mockRouteUnit() {
        RouteUnit result = mock(RouteUnit.class);
        when(result.getDataSourceMapper()).thenReturn(new RouteMapper("foo_ds", "foo_ds_0"));
        when(result.getTableMappers()).thenReturn(Collections.singletonList(new RouteMapper("foo_tbl", "foo_tbl_0")));
        return result;
    }
}

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

package org.apache.shardingsphere.mode.manager.cluster.event.dispatch.subscriber.type;

import com.google.common.base.Preconditions;
import com.google.common.eventbus.Subscribe;
import lombok.RequiredArgsConstructor;
import org.apache.shardingsphere.infra.datasource.pool.props.domain.DataSourcePoolProperties;
import org.apache.shardingsphere.mode.manager.cluster.event.dispatch.event.datasource.unit.StorageUnitAlteredEvent;
import org.apache.shardingsphere.mode.manager.cluster.event.dispatch.event.datasource.unit.StorageUnitRegisteredEvent;
import org.apache.shardingsphere.mode.manager.cluster.event.dispatch.event.datasource.unit.StorageUnitUnregisteredEvent;
import org.apache.shardingsphere.mode.manager.ContextManager;
import org.apache.shardingsphere.mode.manager.cluster.event.dispatch.subscriber.DispatchEventSubscriber;

import java.util.Collections;

/**
 * Storage unit event subscriber.
 */
@RequiredArgsConstructor
public final class StorageUnitEventSubscriber implements DispatchEventSubscriber {
    
    private final ContextManager contextManager;
    
    /**
     * Renew for register storage unit.
     *
     * @param event register storage unit event
     */
    @Subscribe
    public synchronized void renew(final StorageUnitRegisteredEvent event) {
        Preconditions.checkArgument(event.getActiveVersion().equals(
                contextManager.getPersistServiceFacade().getMetaDataPersistService().getMetaDataVersionPersistService().getActiveVersionByFullPath(event.getActiveVersionKey())),
                "Invalid active version: %s of key: %s", event.getActiveVersion(), event.getActiveVersionKey());
        DataSourcePoolProperties dataSourcePoolProps = contextManager
                .getPersistServiceFacade().getMetaDataPersistService().getDataSourceUnitService().load(event.getDatabaseName(), event.getStorageUnitName());
        contextManager.getMetaDataContextManager().getStorageUnitManager().registerStorageUnit(event.getDatabaseName(), Collections.singletonMap(event.getStorageUnitName(), dataSourcePoolProps));
    }
    
    /**
     * Renew for alter storage unit.
     *
     * @param event register storage unit event
     */
    @Subscribe
    public synchronized void renew(final StorageUnitAlteredEvent event) {
        Preconditions.checkArgument(event.getActiveVersion().equals(
                contextManager.getPersistServiceFacade().getMetaDataPersistService().getMetaDataVersionPersistService().getActiveVersionByFullPath(event.getActiveVersionKey())),
                "Invalid active version: %s of key: %s", event.getActiveVersion(), event.getActiveVersionKey());
        DataSourcePoolProperties dataSourcePoolProps = contextManager
                .getPersistServiceFacade().getMetaDataPersistService().getDataSourceUnitService().load(event.getDatabaseName(), event.getStorageUnitName());
        contextManager.getMetaDataContextManager().getStorageUnitManager().alterStorageUnit(event.getDatabaseName(), Collections.singletonMap(event.getStorageUnitName(), dataSourcePoolProps));
    }
    
    /**
     * Renew for unregister storage unit.
     *
     * @param event register storage unit event
     */
    @Subscribe
    public synchronized void renew(final StorageUnitUnregisteredEvent event) {
        Preconditions.checkState(contextManager.getMetaDataContexts().getMetaData().containsDatabase(event.getDatabaseName()), "No database '%s' exists.", event.getDatabaseName());
        contextManager.getMetaDataContextManager().getStorageUnitManager().unregisterStorageUnit(event.getDatabaseName(), event.getStorageUnitName());
    }
}

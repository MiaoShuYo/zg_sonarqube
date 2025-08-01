/*
 * SonarQube
 * Copyright (C) 2009-2025 SonarSource SA
 * mailto:info AT sonarsource DOT com
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
package org.sonar.server.monitoring.ce;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sonar.api.config.Configuration;
import org.sonar.api.utils.System2;
import org.sonar.db.DbClient;
import org.sonar.db.DbSession;
import org.sonar.db.ce.CeActivityDto;
import org.sonar.db.entity.EntityDto;
import org.sonar.server.monitoring.ServerMonitoringMetrics;

import static java.util.Objects.requireNonNull;

public class RecentTasksDurationTask extends ComputeEngineMetricsTask {

  private static final Logger LOGGER = LoggerFactory.getLogger(RecentTasksDurationTask.class);
  private final System2 system;

  private long lastUpdatedTimestamp;

  public RecentTasksDurationTask(DbClient dbClient, ServerMonitoringMetrics metrics, Configuration config,
    System2 system) {
    super(dbClient, metrics, config);
    this.system = system;
    this.lastUpdatedTimestamp = system.now();
  }

  @Override
  public void run() {
    try (DbSession dbSession = dbClient.openSession(false)) {
      List<CeActivityDto> recentSuccessfulTasks = getRecentSuccessfulTasks(dbSession);

      Collection<String> entityUuids = recentSuccessfulTasks.stream()
        .map(CeActivityDto::getEntityUuid)
        .filter(Objects::nonNull)
        .toList();
      List<EntityDto> entities = dbClient.entityDao().selectByUuids(dbSession, entityUuids);
      Map<String, String> entityUuidAndKeys = entities.stream()
        .collect(Collectors.toMap(EntityDto::getUuid, EntityDto::getKey));

      reportObservedDurationForTasks(recentSuccessfulTasks, entityUuidAndKeys);
    }
    lastUpdatedTimestamp = system.now();
  }

  private List<CeActivityDto> getRecentSuccessfulTasks(DbSession dbSession) {
    List<CeActivityDto> recentTasks = dbClient.ceActivityDao().selectNewerThan(dbSession, lastUpdatedTimestamp);
    return recentTasks.stream()
      .filter(c -> c.getStatus() == CeActivityDto.Status.SUCCESS)
      .toList();
  }

  private void reportObservedDurationForTasks(List<CeActivityDto> tasks, Map<String, String> entityUuidAndKeys) {
    for (CeActivityDto task : tasks) {
      String entityUuid = task.getEntityUuid();
      Long executionTimeMs = task.getExecutionTimeMs();
      try {
        requireNonNull(executionTimeMs);

        if (entityUuid != null) {
          String label = entityUuidAndKeys.get(entityUuid);
          requireNonNull(label);
          metrics.observeComputeEngineTaskDuration(executionTimeMs, task.getTaskType(), label);
        } else {
          metrics.observeComputeEngineSystemTaskDuration(executionTimeMs, task.getTaskType());
        }
      } catch (RuntimeException e) {
        LOGGER.warn("Can't report metric data for a CE task with entity uuid " + entityUuid, e);
      }
    }
  }

}

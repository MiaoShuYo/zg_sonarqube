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
package org.sonar.ce.task.projectanalysis.component;

import javax.annotation.Nullable;
import jakarta.inject.Inject;
import org.sonar.api.utils.MessageException;
import org.sonar.ce.task.projectanalysis.analysis.MutableAnalysisMetadataHolder;
import org.sonar.scanner.protocol.output.ScannerReport;
import org.sonar.server.project.DefaultBranchNameResolver;
import org.sonar.db.component.BranchType;

import static org.sonar.scanner.protocol.output.ScannerReport.Metadata.BranchType.UNSET;

public class BranchLoader {
  private final MutableAnalysisMetadataHolder metadataHolder;
  private final BranchLoaderDelegate delegate;
  private final DefaultBranchNameResolver defaultBranchNameResolver;

  public BranchLoader(MutableAnalysisMetadataHolder metadataHolder, DefaultBranchNameResolver defaultBranchNameResolver) {
    this(metadataHolder, null, defaultBranchNameResolver);
  }

  @Inject
  public BranchLoader(MutableAnalysisMetadataHolder metadataHolder, @Nullable BranchLoaderDelegate delegate,
    DefaultBranchNameResolver defaultBranchNameResolver) {
    this.metadataHolder = metadataHolder;
    this.delegate = delegate;
    this.defaultBranchNameResolver = defaultBranchNameResolver;
  }

  public void load(ScannerReport.Metadata metadata) {
    if (delegate != null) {
      delegate.load(metadata);
    } else if (hasBranchProperties(metadata)) {
      // 移除版本限制，允许Community Edition支持分支功能
      // 创建基于分支属性的分支对象
      String branchName = metadata.getBranchName();
      if (!branchName.isEmpty()) {
        // 创建非main分支
        metadataHolder.setBranch(new CommunityBranchImpl(branchName, false));
      } else if (!metadata.getPullRequestKey().isEmpty()) {
        // 创建Pull Request分支
        metadataHolder.setBranch(new CommunityBranchImpl(metadata.getPullRequestKey(), BranchType.PULL_REQUEST));
      } else {
        // 默认使用main分支
        metadataHolder.setBranch(new DefaultBranchImpl(defaultBranchNameResolver.getEffectiveMainBranchName()));
      }
    } else {
      metadataHolder.setBranch(new DefaultBranchImpl(defaultBranchNameResolver.getEffectiveMainBranchName()));
    }
  }

  private static boolean hasBranchProperties(ScannerReport.Metadata metadata) {
    return !metadata.getBranchName().isEmpty()
      || !metadata.getPullRequestKey().isEmpty()
      || !metadata.getReferenceBranchName().isEmpty()
      || metadata.getBranchType() != UNSET;
  }

}

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

import org.sonar.ce.task.projectanalysis.analysis.Branch;
import org.sonar.db.component.BranchType;

/**
 * Implementation of {@link Branch} for Community Edition branches.
 * This allows Community Edition to support non-main branches and pull requests.
 */
public class CommunityBranchImpl implements Branch {
  private final String branchName;
  private final boolean isMain;
  private final BranchType branchType;
  private final String pullRequestKey;

  public CommunityBranchImpl(String branchName, boolean isMain) {
    this.branchName = branchName;
    this.isMain = isMain;
    this.branchType = BranchType.BRANCH;
    this.pullRequestKey = null;
  }

  public CommunityBranchImpl(String pullRequestKey, BranchType branchType) {
    this.branchName = pullRequestKey;
    this.isMain = false;
    this.branchType = branchType;
    this.pullRequestKey = pullRequestKey;
  }

  @Override
  public BranchType getType() {
    return branchType;
  }

  @Override
  public boolean isMain() {
    return isMain;
  }

  @Override
  public String getReferenceBranchUuid() {
    throw new IllegalStateException("Not valid for Community Edition branches");
  }

  @Override
  public String getName() {
    return branchName;
  }

  @Override
  public boolean supportsCrossProjectCpd() {
    return isMain;
  }

  @Override
  public String getPullRequestKey() {
    if (branchType != BranchType.PULL_REQUEST) {
      throw new IllegalStateException("Only a branch of type PULL_REQUEST can have a pull request id.");
    }
    return pullRequestKey;
  }

  @Override
  public String getTargetBranchName() {
    throw new IllegalStateException("Only on a pull request");
  }
} 
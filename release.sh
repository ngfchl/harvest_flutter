#!/usr/bin/env bash
set -euo pipefail

REMOTE="origin"
SOURCE_BRANCH="dev"
TARGET_BRANCH="master"
BUILD_BRANCH="build"
PUBSPEC_FILE="pubspec.yaml"
DRY_RUN=false

usage() {
  cat <<'EOF'
用法: ./release.sh [选项]

选项:
  --source <分支>      发布源分支。默认: dev
  --target <分支>      合并目标分支。默认: master
  --build <分支>       构建分支，将源分支合并到此分支。默认: build
  --remote <远程>      Git 远程仓库。默认: origin
  --pubspec <文件>     pubspec.yaml 路径。默认: pubspec.yaml
  --dry-run            模拟完整流程，不执行实际 git 操作
  -h, --help           显示帮助信息

流程:
  1. 切换到源分支并拉取最新代码。
  2. 根据 pubspec.yaml 计算下一个版本号。
  3. 显示 旧版本 => 新版本 并请求确认。
  4. 更新 pubspec.yaml 并在源分支提交版本号变更。
  5. 确认后将源分支合并到目标分支。
  6. 确认后将源分支合并到构建分支。
  7. 确认后创建发布标签。
  8. 确认后推送源分支、目标分支、构建分支和标签。
EOF
}

confirm() {
  local message="$1"
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] 自动确认: $message"
    return 0
  fi
  local answer=""
  read -r -p "$message [按回车继续] " answer
  case "$answer" in
    ""|y|Y) return 0 ;;
    *) echo "已取消: $message"; return 1 ;;
  esac
}

run() {
  echo "+ $*"
  if [ "$DRY_RUN" = true ]; then
    return 0
  fi
  "$@"
}

current_branch() {
  git branch --show-current
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少命令: $1" >&2
    exit 1
  fi
}

require_clean_worktree() {
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] 跳过工作区检查"
    return 0
  fi
  if [ -n "$(git status --porcelain)" ]; then
    echo "当前工作区不干净，请先提交或暂存现有改动后再发布。" >&2
    git status --short
    exit 1
  fi
}

read_version() {
  local file="$1"
  awk '/^version:[[:space:]]*/ { print $2; exit }' "$file"
}

calc_next_version() {
  local old_version="$1"
  local today old_date old_count old_build next_count next_build

  if [[ ! "$old_version" =~ ^([0-9]{4}\.[0-9]{4})\.([0-9]+)\+([0-9]+)$ ]]; then
    echo "版本号格式不符合 YYYY.MMDD.XX+build: $old_version" >&2
    exit 1
  fi

  old_date="${BASH_REMATCH[1]}"
  old_count="${BASH_REMATCH[2]}"
  old_build="${BASH_REMATCH[3]}"
  today="$(date '+%Y.%m%d')"

  if [ "$old_date" = "$today" ]; then
    next_count=$((10#$old_count + 1))
  else
    next_count=1
  fi
  next_build=$((10#$old_build + 1))

  printf '%s.%02d+%d\n' "$today" "$next_count" "$next_build"
}

update_pubspec_version() {
  local file="$1"
  local new_version="$2"

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] 将更新 $file 中版本号为 $new_version"
    return 0
  fi

  local tmp_file

  tmp_file="$(mktemp)"
  awk -v version="$new_version" '
    BEGIN { replaced = 0 }
    /^version:[[:space:]]*/ && replaced == 0 {
      print "version: " version
      replaced = 1
      next
    }
    { print }
    END {
      if (replaced == 0) {
        exit 2
      }
    }
  ' "$file" > "$tmp_file" || {
    rm -f "$tmp_file"
    echo "更新版本号失败，未找到 version 字段: $file" >&2
    exit 1
  }
  mv "$tmp_file" "$file"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --source)
      SOURCE_BRANCH="${2:-}"
      shift 2
      ;;
    --target)
      TARGET_BRANCH="${2:-}"
      shift 2
      ;;
    --build)
      BUILD_BRANCH="${2:-}"
      shift 2
      ;;
    --remote)
      REMOTE="${2:-}"
      shift 2
      ;;
    --pubspec)
      PUBSPEC_FILE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1" >&2
      usage
      exit 1
      ;;
  esac
done

require_command git
require_command awk
require_command date
require_command mktemp

cd "$(git rev-parse --show-toplevel)"

if [ "$DRY_RUN" = true ]; then
  echo "========================================="
  echo "  DRY-RUN 模式：不会执行实际 git 操作"
  echo "========================================="
fi

if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "未找到文件: $PUBSPEC_FILE" >&2
  exit 1
fi

INITIAL_BRANCH="$(current_branch)"

require_clean_worktree

run git fetch "$REMOTE" --prune --tags
run git checkout "$SOURCE_BRANCH"
run git pull --ff-only "$REMOTE" "$SOURCE_BRANCH"

OLD_VERSION="$(read_version "$PUBSPEC_FILE")"
NEW_VERSION="$(calc_next_version "$OLD_VERSION")"
TAG_NAME="$NEW_VERSION"

echo "发布分支: $SOURCE_BRANCH => $TARGET_BRANCH"
if [ -n "$BUILD_BRANCH" ]; then
  echo "构建分支: $SOURCE_BRANCH => $BUILD_BRANCH"
fi
echo "版本变更: $OLD_VERSION => $NEW_VERSION"
echo "Tag: $TAG_NAME"

confirm "确认计算版本号并写入 $PUBSPEC_FILE" || exit 1

update_pubspec_version "$PUBSPEC_FILE" "$NEW_VERSION"
run git diff -- "$PUBSPEC_FILE"

confirm "确认提交版本号 $NEW_VERSION 到 $SOURCE_BRANCH" || {
  run git checkout -- "$PUBSPEC_FILE"
  run git checkout "$INITIAL_BRANCH"
  exit 1
}

run git add "$PUBSPEC_FILE"
run git commit -m "release: 更新版本号 $NEW_VERSION"

confirm "确认将 $SOURCE_BRANCH 合并到 $TARGET_BRANCH" || exit 1
run git checkout "$TARGET_BRANCH"
run git pull --ff-only "$REMOTE" "$TARGET_BRANCH"
run git merge "$SOURCE_BRANCH"

if [ -n "$BUILD_BRANCH" ]; then
  confirm "确认将 $SOURCE_BRANCH 合并到 $BUILD_BRANCH" || exit 1
  run git checkout "$BUILD_BRANCH"
  run git pull --ff-only "$REMOTE" "$BUILD_BRANCH"
  run git merge "$SOURCE_BRANCH"
fi

confirm "确认创建标签 $TAG_NAME" || exit 1
if [ "$DRY_RUN" = false ]; then
  if git rev-parse "refs/tags/$TAG_NAME" >/dev/null 2>&1; then
    echo "标签已存在: $TAG_NAME" >&2
    exit 1
  fi
fi
run git tag "$TAG_NAME" "$SOURCE_BRANCH"

confirm "确认推送分支和标签到 $REMOTE" || exit 1
run git push "$REMOTE" "$SOURCE_BRANCH"
run git push "$REMOTE" "$TARGET_BRANCH"
if [ -n "$BUILD_BRANCH" ]; then
  run git push "$REMOTE" "$BUILD_BRANCH"
fi
run git push "$REMOTE" "$TAG_NAME"

run git checkout "$SOURCE_BRANCH"

echo "发布完成: $OLD_VERSION => $NEW_VERSION"

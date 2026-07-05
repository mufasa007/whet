## 修改摘要

## 回归测试结果

运行 `bash scripts/regression-test.sh` 的结果：

```
（请粘贴完整输出）
```

## 破坏性变更

- [ ] MAJOR — 破坏性变更（agent/skill/command 重命名或删除、台账结构变更、hook 规则收紧）
- [ ] MINOR — 新增能力（新 agent、skill、command、模板）
- [ ] PATCH — 修复/优化（文档修正、提示词调整、bug 修复）

## 检查清单

- [ ] 新增/修改的 agent 已同步到 `hooks/scripts/enforce-model-tier.sh` 的 case 语句
- [ ] `README.md` 中英文说明已同步更新
- [ ] `CHANGELOG.md` 已添加变更条目
- [ ] 回归测试全部通过（0 失败）

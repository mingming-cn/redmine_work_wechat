# 简介

企业微信通知插件，支持特性如下：

* 新建问题通知
* 更新问题通知
* `redmine:send_work_wechat` 定期任务通知待完成任务
* 支持 Redmine 5.x

# 安装

1. `cd ${REDMINE_ROOT}/plugins`
2. `git clone https://github.com/mingming-cn/redmine_work_wechat.git`
3. 进入插件页面配置相关参数，管理 > 插件 > Redmine Work Wechat plugin > 配置

# Task 使用方法

> Available options:
> * :days     => how many days in the future to remind about (defaults to 7)
> * :tracker  => id of tracker for filtering issues (defaults to all trackers)
> * :project  => id or identifier of project to process (defaults to all projects)
> * :users    => array of user/group ids who should be reminded
> * :version  => name of target version for filtering issues (defaults to none)

```bash
rake redmine:send_work_wechat days=10 RAILS_ENV="production"
```

# 截图

## 插件配置
![](assets/images/plugin_config.png)

## 新问题通知
![](assets/images/msg_new_issue.png)

## 问题更新通知
![](assets/images/msg_issue_updated.png)

## 定期任务通知
![](assets/images/msg_task.png)

# hexo commands

**hexo 部署**

本地部署测试页面：

```bash
hexo server
hexo s
```

清理缓存`public`以及`db.json`

```bash
hexo clean
```

生成`hexo`静态文件

```bash
hexo generate
hexo g
```

部署到 Github

```bash
hexo deploy
hexo d
```



**文章写作**

新建一篇文章，文章可用指定`tags`、`categories`

```bash
hexo new <new_post_name>
hexo n <new_post_name>
```

新建草稿

```bash
hexo n draft <new_draft_name>
```

预览草稿

```bash
hexo s --draft
```

发布草稿

```bash
hexo publish <draft_name>
```




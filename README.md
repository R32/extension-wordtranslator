羊毛查词
--------

这是一个极度轻量化的用于 chromium 类浏览器的单词或短句插件，其目的是取代国内不再可用的“google 翻译插件”

**重要** 此插件是通过与 [微软必应翻译网页](https://cn.bing.com/translator) 互动来实现的，
因此浏览器需要 **至少保持一个翻译网页作为后台**, 并设置好输入框和输出框的语言

> 如果翻译网页不存在, 此插件会自动打开一个并跳转过去激活窗口
>
> 因为插件的底层原理是 : (1)复制选中的英文 (2)然后把文本粘贴到翻译网页的输入窗口 (3)取回结果并显示
>
> 薅微软的羊毛, 所以叫羊毛查词

### 安装

插件仅适用于 chromium 类型的浏览器, 例如 : `brave`(推荐), `ungoogled chromium`, `微软 edge` 或者 `chrome`

1. **[下载](https://github.com/R32/extension-wordtranslator/archive/master.zip)** 并且 **解压**, 或直接 `git clone` 克隆这个项目

2. 进入浏览器的 “管理扩展程序”，(或在浏览器的地址栏中输入 : `chrome://extensions/` )

3. 激活 "开发者模式" 选项

4. 点击 “加载已解压的扩展程序” 按钮，选择 **`build`** 目录即可

### 使用

双击或选中文本，左键点击弹出的小窗口将翻译文本，右键则为关闭

点击此插件图标后显示的菜单大致如下 :

```
启用             [x]
重定向 GoogleAPI [ ]
发音     (0-2-4-8-~)
```
注意: 发音 **不是** 用于音量, 而用于表示单词数量, 其范围为 `[0, 2, 4, 8, 无限]`,
例如当值为 2 时, 那么选中的英文单词不超过 2 个时下才会发音

对于 `重定向 GoogleAPI`, 目前仅有两个可用, 分别为 :

- 用于 recaptcha 验证

- 对 googleapi 资源的引用, 例如 脚本, 图片, 以及字体


也可自己添加或修改目录中的 [`redirect-googleapi.json`](build/redirect-googleapi.json) 文件,
例如 : 重定向 github 单个文件的下载(需要复制链接到地址栏, 或者点击那个 `raw` 的按钮才有效)

```json
{
	"id": 3,
	"priority": 2,
	"condition": {
		"regexFilter": "https://raw.githubusercontent.com/(.*)",
		"resourceTypes": ["main_frame"]
	},
	"action": {
		"type": "redirect",
		"redirect": {
			"regexSubstitution": "https://cdn.githubraw.com/\\1"
		}
	}
}
```

### 常见问题

- 选中文本后点击小窗口没反应, 或没有发音, 或者出现 "executeScript error"

    这是由于浏览器会回收"不活动的页面", 因此切换到"必应翻译"网页, 并在网页上随便点下或刷新

### 更新

- 2024-4-18 : 对 bing/translator 的更新做了处理, 并提高版本到了 1.1

- 2024-1-8 : 由单词的数量 `[0,2,4,8,~]` 决定是否发音

- 2023-11-21 `@fbabd93`: 添加了 googleapi 的重定向功能(默认为关闭, 要自己点击插件图标的弹出窗口)

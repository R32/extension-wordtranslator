羊毛查词
--------

这是一个极度轻量化的用于 chromium 类浏览器的单词或短句划词翻译插件，其目的是取代国内不再可用的“google 翻译插件”

**重要** 此插件是通过与 [微软必应翻译网页](https://cn.bing.com/translator) 互动来实现的，
因此浏览器需要 **至少保持一个翻译网页作为后台**, 并设置好输入框和输出框的语言

> 如果翻译网页不存在, 此插件会自动打开一个并跳转过去激活窗口
>
> 因为插件的底层原理是 : (1)复制选中的英文 (2)然后把文本粘贴到翻译网页的输入窗口 (3)取回结果并显示
>
> 薅微软的羊毛, 所以叫羊毛查词

此插件适用于经常需要看英语文档或小说的人, 划词可发音(默认为 4个单词内, 可自己调整为 8 个或无限)

相较于其它同类型插件的优点 :

- CPU, 内存占用低 (所有代码没有压缩仅仅才 12KB 左右, 不使用任何第三方库)

- 完全没有任何费用

- 不上传, 不收集任何数据

缺点 :

- 浏览器需要保持一个的 "必应翻译" 网页作为后台

- 不支持 PDF 文件 (对于 PDF, 强烈推荐Win10+ 自带的 EDGE 浏览器, 自带了对 PDF 的划词翻译)

### 安装

- [**Firefox 浏览器**](https://addons.mozilla.org/zh-CN/firefox/addon/羊毛查词) 注意安装完成后 **需要** 进入此插件的管理面板, 在 `权限` 选项卡中把 `访问您在所有网站的数据` 勾上

- [**微软 edge**](https://microsoftedge.microsoft.com/addons/detail/nbgpdjbjdombofpabcedaohpagbblghm)

- 其它浏览器需要手动安装, 例如 : `brave`, `ungoogled chromium`, 或其它 chromium 类型的浏览器

  1. **[下载](https://github.com/R32/extension-wordtranslator/archive/master.zip)** 并且 **解压**, 或直接 `git clone` 克隆这个项目

  2. 进入浏览器的 “管理扩展程序”，(或在浏览器的地址栏中输入 : `chrome://extensions/` )

  3. 激活 "开发者模式" 选项

  4. 点击 “加载已解压的扩展程序” 按钮，选择 **`build`** 目录即可

对于一些权限 如 : `允许访问文件 URL` 和 `InPrivate 模式` 需要自己在插件管理里设置

### 使用

双击或选中文本，左键点击弹出的小窗口将翻译文本，右键则为关闭

点击此插件图标后显示的菜单大致如下 :

```
启用             [x]
重定向 GoogleAPI [ ]
发音     (0-2-4-8-~)
```
**重点:** 发音 **不是** 用于音量, 而用于表示单词数量, 其范围为 `[0, 2, 4, 8, 无限]`,
例如当值为 2 时, 那么选中的英文单词不超过 2 个时下才会发音

对于 `重定向 GoogleAPI`, 目前只有一下两个可用(默认是关闭的, 需要自己启用):

- 重定向了 recaptcha, 用于通过一些网页的 Google 机器人检测

- 重定向了 googleapi 的脚本, 图片, 以及字体, 用于更快地打开一些网页, 例如 : stackoverflow

重定向的规则可参见 [`redirect-googleapi.json`](build/redirect-googleapi.json),
如果你是以"文件的形式"安装的此插件, 可以自己修改规则.

### 常见问题

- 选中文本后点击 `弹出小窗口` 没反应, 或没有发音

    这是由于浏览器会回收"不活动的页面", 因此要自己切换到 "必应翻译" 网页, 并在网页上随便点下或刷新

- 点击 `弹出小窗口` 后, 弹出`[object Object]`

    绝大多数情况下, 再次点击一次 `弹出小窗口` 可以解决此问题, 或参考上一个问题的解决方案去激活下页面

### 更新

- 2025-2-27:

  - 更新了 `hook.js` 的兼容性, 因为 "必应翻译" 的更新将之前的 `TEXTAREA` 改成了 `DIV`.
  - 将一个闭包函数移出到外部, 轻量地改善了 `background.js` 的内存占用.
  - 版本提高到了 `1.2.3`

- 2024-6-8 :

  - 使用了 `Tabs.sendMessage()` 代替了不合适的 `Scripting.executeScript()` (_从来没有人和我说过这个问题_)
  - 使用了直接简单的函数风格代替了之前的 class 风格, 以生成更简洁的代码
  - 版本提高到了 1.2.0

- 2024-4-18 : 对 bing/translator 的更新做了处理, 并提高版本到了 1.1

- 2024-1-8 : 由单词的数量 `[0,2,4,8,~]` 决定是否发音

- 2023-11-21 `@fbabd93`: 添加了 googleapi 的重定向功能(默认为关闭, 要自己点击插件图标的弹出窗口)

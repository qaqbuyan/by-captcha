--[[
    @author Bunyan <buyan@mail.qaqbuyan.com>
    @link https://github.com/qaqbuyan/by-captcha/blob/main/view/lua-waf/config.lua
    @description BUYAN CAPTCHA configuration file
    @date 2026-05-07
]]

-- Buyan-Captcha 人机验证配置
BuyanCaptchaEnable = "on"-- 是否启用人机验证拦截
BuyanAppId = "Your Buyan Captcha App ID"--  Buyan-Captcha App ID
BuyanClickMode = "none"-- 点击模式: none(自动显示) / auto(无感) / #id(监听元素) / .class(监听类)
BuyanTokenFailAction = "error"-- Token获取失败处理方式: error(显示错误页面) / pass(直接放行)
BuyanVerifyFailAction = "error"-- 验证接口请求失败处理方式: error(返回验证失败) / pass(直接放行)
BuyanVerifyCookieName = "_buyan_captcha_verify"-- 验证通过的Cookie名称
BuyanVerifyExpireTime = 604800-- 验证通过有效期（秒）- 7天
BuyanCaptchaLanguage = "zh-CN"-- 默认界面语言: zh-CN(简体中文) / zh-TW(繁体中文) / en(English) / ja(日本語) / ko(한국어)。优先自动识别，识别失败时使用此默认配置
-- 需要排除验证码验证的路径
BuyanCaptchaExcludePaths={
    "^/images/",           -- 图片目录
    "\\.(jpg|jpeg|png|gif|webp|svg|ico)$",  -- 图片文件
    "\\.(css|js)$",        -- CSS和JS文件
    "\\.(woff|woff2|ttf|eot|otf)$",  -- 字体文件
    "\\.(mp4|mp3|wav|ogg|webm)$",     -- 音视频文件
    "^/static/",           -- 静态资源目录
    "^/assets/",           -- 资源目录
    "^/favicon\\.ico$",    -- 网站图标
    "^/robots\\.txt$",     -- 爬虫规则
    "^/sitemap",           -- 站点地图
}
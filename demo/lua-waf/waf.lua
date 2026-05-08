--[[
    @author Bunyan <buyan@mail.qaqbuyan.com>
    @link https://github.com/qaqbuyan/by-captcha/blob/main/view/lua-waf/waf.lua
    @description BUYAN CAPTCHA checks the main module
    @date 2026-05-07
]]

-- 验证码检查主模块
-- 用于处理人机验证拦截

require 'config'

local optionIsOn = function(options) return options == "on" and true or false end

-- 加载验证码模块
local captcha_module = nil
local BuyanCaptchaEnable = optionIsOn(BuyanCaptchaEnable or "off")

ngx.log(ngx.INFO, "SplitCaptcha loading - Enable: ", tostring(BuyanCaptchaEnable))
if BuyanCaptchaEnable then
    local ok, mod = pcall(require, 'init')
    if ok then
        captcha_module = mod
        ngx.log(ngx.INFO, "SplitCaptcha module loaded successfully")
    else
        ngx.log(ngx.ERR, "Failed to load splitcaptcha module: ", tostring(mod))
    end
else
    ngx.log(ngx.INFO, "SplitCaptcha disabled, skipping module load")
end

-- 执行验证码检查
if BuyanCaptchaEnable and captcha_module then
    captcha_module.check_captcha()
end
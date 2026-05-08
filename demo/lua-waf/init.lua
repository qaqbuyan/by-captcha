--[[
    @author Bunyan <buyan@mail.qaqbuyan.com>
    @link https://github.com/qaqbuyan/by-captcha/blob/main/view/lua-waf/init.lua
    @description BUYAN CAPTCHA core logic module
    @date 2026-05-07
]]

require 'config'

local ngxmatch = ngx.re.match
local optionIsOn = function(options) return options == "on" and true or false end

-- 加载配置变量
local BUYAN_API_HOST = "qaqbuyan.com"
local BUYAN_API_PORT = 88
local BUYAN_APPID = BuyanAppId
local BUYAN_CLICK_MODE = BuyanClickMode or "none"
local BUYAN_TOKEN_FAIL_ACTION = BuyanTokenFailAction or "error"
local BUYAN_VERIFY_FAIL_ACTION = BuyanVerifyFailAction or "error"
local VERIFY_COOKIE_NAME = BuyanVerifyCookieName or "_buyan_captcha_verify"
local VERIFY_CACHE_PREFIX = "buyan_captcha_verify:"
local VERIFY_EXPIRE_TIME = BuyanVerifyExpireTime or 604800
local EXCLUDE_PATHS = BuyanCaptchaExcludePaths or {}
local BuyanCaptchaEnable = optionIsOn(BuyanCaptchaEnable or "off")
local CAPTCHA_LANGUAGE = BuyanCaptchaLanguage or "zh-CN"

local _M = {}

-- 多语言配置
local LANG_PACK = {
    ["zh-CN"] = {
        title = "正在进行安全验证",
        description = "本网站使用安全服务防护恶意自动程序。在验证您不是自动程序期间，将显示此页面。",
        loading = "正在加载验证码...",
        error_msg = "验证码加载失败，请刷新页面重试",
        retry_btn = "刷新页面",
        verify_notice = "请先验证您不是自动程序才可以访问网站",
        footer_captcha = "安全验证保护中",
        footer_privacy = "隐私政策",
        success_title = "验证成功。正在等待 %s 响应...",
        error_config_title = "人机验证配置错误",
        error_config_h1 = "人机验证服务配置错误",
        error_config_code = "Error: BuyanAppId not configured",
        error_config_desc = "人机验证服务未正确配置，无法完成安全验证。",
        error_token_title = "人机验证暂时不可用",
        error_token_h1 = "人机验证服务令牌错误",
        error_token_code = "Error: Cannot obtain BuyanToken",
        error_token_desc = "人机验证服务未获取到令牌，无法完成安全验证。",
        powered_by = "Powered by Buyan-Captcha"
    },
    ["zh-TW"] = {
        title = "正在進行安全驗證",
        description = "本網站使用安全服務防護惡意自動程序。在驗證您不是自動程序期間，將顯示此頁面。",
        loading = "正在載入驗證碼...",
        error_msg = "驗證碼載入失敗，請重新整理頁面重試",
        retry_btn = "重新整理頁面",
        verify_notice = "請先驗證您不是自動程序才可以訪問網站",
        footer_captcha = "安全驗證保護中",
        footer_privacy = "隱私政策",
        success_title = "驗證成功。正在等待 %s 回應...",
        error_config_title = "人機驗證配置錯誤",
        error_config_h1 = "人機驗證服務配置錯誤",
        error_config_code = "Error: BuyanAppId not configured",
        error_config_desc = "人機驗證服務未正確配置，無法完成安全驗證。",
        error_token_title = "人機驗證暫時不可用",
        error_token_h1 = "人機驗證服務令牌錯誤",
        error_token_code = "Error: Cannot obtain BuyanToken",
        error_token_desc = "人機驗證服務未獲取到令牌，無法完成安全驗證。",
        powered_by = "Powered by Buyan-Captcha"
    },
    ["en"] = {
        title = "Security Verification in Progress",
        description = "This website uses security services to protect against malicious automated programs. This page will be displayed while verifying that you are not a bot.",
        loading = "Loading captcha...",
        error_msg = "Failed to load captcha, please refresh the page to retry",
        retry_btn = "Refresh Page",
        verify_notice = "Please verify that you are not a bot to access the website",
        footer_captcha = "Security Protection Active",
        footer_privacy = "Privacy Policy",
        success_title = "Verification successful. Waiting for %s response...",
        error_config_title = "Captcha Configuration Error",
        error_config_h1 = "Captcha Service Configuration Error",
        error_config_code = "Error: BuyanAppId not configured",
        error_config_desc = "The captcha service is not properly configured and cannot complete security verification.",
        error_token_title = "Captcha Service Temporarily Unavailable",
        error_token_h1 = "Captcha Service Token Error",
        error_token_code = "Error: Cannot obtain BuyanToken",
        error_token_desc = "The captcha service failed to obtain a token and cannot complete security verification.",
        powered_by = "Powered by Buyan-Captcha"
    },
    ["ja"] = {
        title = "セキュリティ認証を実行中",
        description = "このウェブサイトは、悪意のある自動プログラムから保護するためにセキュリティサービスを使用しています。ボットでないことを確認している間、このページが表示されます。",
        loading = "認証コードを読み込み中...",
        error_msg = "認証コードの読み込みに失敗しました。ページを更新して再試行してください",
        retry_btn = "ページを更新",
        verify_notice = "ウェブサイトにアクセスするには、ボットでないことを確認してください",
        footer_captcha = "セキュリティ保護有効",
        footer_privacy = "プライバシーポリシー",
        success_title = "認証に成功しました。%s の応答を待っています...",
        error_config_title = "認証設定エラー",
        error_config_h1 = "認証サービス設定エラー",
        error_config_code = "Error: BuyanAppId not configured",
        error_config_desc = "認証サービスが正しく設定されていないため、セキュリティ認証を完了できません。",
        error_token_title = "認証サービスは一時的に利用できません",
        error_token_h1 = "認証サービストークンエラー",
        error_token_code = "Error: Cannot obtain BuyanToken",
        error_token_desc = "認証サービスがトークンを取得できなかったため、セキュリティ認証を完了できません。",
        powered_by = "Powered by Buyan-Captcha"
    },
    ["ko"] = {
        title = "보안 인증 진행 중",
        description = "이 웹사이트는 악성 자동 프로그램으로부터 보호하기 위해 보안 서비스를 사용합니다. 봇이 아님을 확인하는 동안 이 페이지가 표시됩니다.",
        loading = "인증 코드 로드 중...",
        error_msg = "인증 코드 로드에 실패했습니다. 페이지를 새로고침하여 다시 시도하세요",
        retry_btn = "페이지 새로고침",
        verify_notice = "웹사이트에 접근하려면 봇이 아님을 인증해 주세요",
        footer_captcha = "보안 보호 활성화",
        footer_privacy = "개인정보처리방침",
        success_title = "인증 성공. %s 응답 대기 중...",
        error_config_title = "인증 설정 오류",
        error_config_h1 = "인증 서비스 설정 오류",
        error_config_code = "Error: BuyanAppId not configured",
        error_config_desc = "인증 서비스가 올바르게 구성되지 않아 보안 인증을 완료할 수 없습니다.",
        error_token_title = "인증 서비스 일시적으로 사용 불가",
        error_token_h1 = "인증 서비스 토큰 오류",
        error_token_code = "Error: Cannot obtain BuyanToken",
        error_token_desc = "인증 서비스가 토큰을 가져오지 못해 보안 인증을 완료할 수 없습니다.",
        powered_by = "Powered by Buyan-Captcha"
    }
}

-- 从请求头获取语言
local function get_language_from_header()
    local accept_lang = ngx.var.http_accept_language
    if not accept_lang or accept_lang == "" then
        return nil
    end

    -- 语言优先级映射 (从 Accept-Language 提取)
    local lang_map = {
        ["zh-CN"] = "zh-CN",
        ["zh-cn"] = "zh-CN",
        ["zh"] = "zh-CN",
        ["zh-TW"] = "zh-TW",
        ["zh-tw"] = "zh-TW",
        ["zh-HK"] = "zh-TW",
        ["zh-hk"] = "zh-TW",
        ["en"] = "en",
        ["en-US"] = "en",
        ["en-GB"] = "en",
        ["ja"] = "ja",
        ["ja-JP"] = "ja",
        ["ko"] = "ko",
        ["ko-KR"] = "ko"
    }

    -- 解析 Accept-Language 头部 (格式如: zh-CN,zh;q=0.9,en;q=0.8)
    for lang in accept_lang:gmatch("([a-zA-Z%-]+)") do
        local mapped = lang_map[lang]
        if mapped and LANG_PACK[mapped] then
            return mapped
        end
    end

    return nil
end

-- 获取当前语言
local function get_current_language()
    local header_lang = get_language_from_header()
    if header_lang then
        return header_lang
    end
    return CAPTCHA_LANGUAGE
end

-- 获取当前语言的文本
local function get_text(key, ...)
    local current_lang = get_current_language()
    local lang = LANG_PACK[current_lang] or LANG_PACK["zh-CN"]
    local text = lang[key] or LANG_PACK["zh-CN"][key] or key
    if ... then
        text = string.format(text, ...)
    end
    return text
end

-- 简单的JSON解析函数
local function simple_json_decode(str)
    if not str or str == "" then
        return nil, "empty string"
    end

    local json_start = str:find('[{%[]')
    if not json_start then
        return nil, "no json object found"
    end

    local json_end = #str
    for i = #str, 1, -1 do
        local char = str:sub(i, i)
        if char == "}" or char == "]" then
            json_end = i
            break
        end
    end

    local clean_str = str:sub(json_start, json_end)
    local result = {}

    local code = clean_str:match('"code"%s*:%s*(%-?%d+)')
    if code then
        result.code = tonumber(code)
    end

    local token = clean_str:match('"token"%s*:%s*"([^"]+)"')
    if token then
        if not result.message then
            result.message = {}
        end
        result.message.token = token
    end

    local expire = clean_str:match('"expire"%s*:%s*"([^"]+)"')
    if expire then
        if not result.message then
            result.message = {}
        end
        result.message.expire = expire
    end

    local valid = clean_str:match('"valid"%s*:%s*(true)%s*[,%}]')
    if not valid then
        valid = clean_str:match('"valid"%s*:%s*(false)%s*[,%}]')
    end
    if valid then
        if not result.message then
            result.message = {}
        end
        result.message.valid = valid == "true"
    end

    local host = clean_str:match('"host"%s*:%s*"([^"]+)"')
    if host then
        if not result.message then
            result.message = {}
        end
        result.message.host = host
    end

    return result
end

-- 发送HTTP GET请求
local function http_get(host, port, path, use_ssl)
    local sock = ngx.socket.tcp()
    sock:settimeout(5000)

    local ok, err = sock:connect(host, port)
    if not ok then
        ngx.log(ngx.ERR, "HTTP connect failed: ", err)
        return nil, "connect failed: " .. (err or "unknown")
    end

    if use_ssl then
        local session, err = sock:sslhandshake(false, "qaqbuyan.com", false)
        if not session then
            sock:close()
            ngx.log(ngx.ERR, "SSL handshake failed: ", err)
            return nil, "ssl handshake failed: " .. (err or "unknown")
        end
    end

    local request = "GET " .. path .. " HTTP/1.1\r\n" ..
                    "Host: qaqbuyan.com\r\n" ..
                    "User-Agent: Buyan-Captcha/1.0\r\n" ..
                    "Accept: application/json\r\n" ..
                    "Connection: close\r\n\r\n"

    local bytes, err = sock:send(request)
    if not bytes then
        sock:close()
        ngx.log(ngx.ERR, "HTTP send failed: ", err)
        return nil, "send failed: " .. (err or "unknown")
    end

    local response, err, partial = sock:receive("*a")
    sock:close()

    if not response or response == "" then
        response = partial or ""
    end

    if response == "" then
        ngx.log(ngx.ERR, "HTTP empty response")
        return nil, "empty response"
    end

    local status = response:match("HTTP/[%d%.]+ (%d%d%d)")
    if not status then
        ngx.log(ngx.ERR, "Failed to parse HTTP status")
        return nil, "invalid response"
    end

    local body = ""
    local header_end = response:find("\r\n\r\n", 1, true)
    if not header_end then
        header_end = response:find("\n\n", 1, true)
    end
    if header_end then
        body = response:sub(header_end + 4)
    else
        body = response
    end

    return {
        status = tonumber(status),
        body = body
    }
end

-- 获取Token
function _M.get_token()
    if not BUYAN_APPID or BUYAN_APPID == "" then
        ngx.log(ngx.ERR, "BuyanAppId not configured")
        return nil, "appid not configured"
    end

    local path = "/buyan_captcha?update_token&appid=" .. BUYAN_APPID
    local res, err = http_get(BUYAN_API_HOST, BUYAN_API_PORT, path, true)

    if not res then
        ngx.log(ngx.ERR, "Failed to get token: ", err)
        return nil, err
    end

    if res.status ~= 200 then
        ngx.log(ngx.ERR, "Token API returned status: ", res.status)
        return nil, "API error: " .. res.status
    end

    local data = simple_json_decode(res.body)
    if not data then
        ngx.log(ngx.ERR, "Failed to parse token response")
        return nil, "JSON parse error"
    end

    if data.code ~= 200 then
        ngx.log(ngx.ERR, "Token API error code: ", data.code)
        return nil, "API error code: " .. tostring(data.code)
    end

    if data.message and data.message.token then
        return data.message.token, data.message.expire
    end

    return nil, "no token in response"
end

-- 二次验证
function _M.verify_ticket(verifyid)
    if not BUYAN_APPID or BUYAN_APPID == "" then
        ngx.log(ngx.ERR, "BuyanAppId not configured")
        return false, "appid not configured"
    end

    if not verifyid or verifyid == "" then
        return false, "empty verifyid"
    end

    local encoded_verifyid = ngx.escape_uri(verifyid)
    local client_ip = ngx.var.remote_addr or ""
    local user_agent = ngx.var.http_user_agent or ""
    local encoded_ip = ngx.escape_uri(client_ip)
    local encoded_ua = ngx.escape_uri(user_agent)
    local path = "/buyan_captcha?query_params&params=" .. encoded_verifyid .. "&appid=" .. BUYAN_APPID .. "&ip=" .. encoded_ip .. "&ua=" .. encoded_ua

    local res, err = http_get(BUYAN_API_HOST, BUYAN_API_PORT, path, true)

    if not res then
        ngx.log(ngx.ERR, "Failed to verify ticket: ", err)
        if BUYAN_VERIFY_FAIL_ACTION == "pass" then
            return true, {valid = true, bypass = true}
        end
        return false, err
    end

    if res.status ~= 200 then
        ngx.log(ngx.ERR, "Verify API returned status code: ", res.status)
        return false, "API error: " .. res.status
    end

    local data = simple_json_decode(res.body)
    if not data then
        ngx.log(ngx.ERR, "Failed to parse verify response")
        return false, "JSON parse error"
    end

    if data.code ~= 200 then
        ngx.log(ngx.ERR, "Verify API error code: ", data.code)
        return false, "API error code: " .. tostring(data.code)
    end

    if data.message and data.message.valid ~= nil then
        return data.message.valid == true, data.message
    end

    return false, "no valid field in response"
end

-- 检查路径是否在排除列表中
function _M.is_excluded_path(uri)
    for _, pattern in ipairs(EXCLUDE_PATHS) do
        local matched = ngxmatch(uri, pattern, "ijox")
        if matched then
            return true
        end
    end
    return false
end

-- 检查用户是否已通过验证
function _M.is_verified()
    local cookie = ngx.var.http_cookie
    if cookie then
        local pattern = VERIFY_COOKIE_NAME .. "=([a-fA-F0-9]+)"
        local verify_cookie = ngxmatch(cookie, pattern, "ijo")
        if verify_cookie and verify_cookie[1] then
            local cookie_value = verify_cookie[1]
            local limit = ngx.shared.limit
            local cache_key = VERIFY_CACHE_PREFIX .. cookie_value
            local verified = limit:get(cache_key)
            if verified then
                limit:set(cache_key, "1", VERIFY_EXPIRE_TIME)
                return true
            end
        end
    end
    return false
end

-- 设置验证通过状态
function _M.set_verified()
    local limit = ngx.shared.limit
    local client_ip = ngx.var.remote_addr or "unknown"
    local user_agent = ngx.var.http_user_agent or ""
    local timestamp = ngx.time()
    local random_str = tostring(math.random(1000000000, 9999999999))
    local cookie_value = ngx.md5(client_ip .. user_agent .. timestamp .. random_str)

    local cache_key = VERIFY_CACHE_PREFIX .. cookie_value
    limit:set(cache_key, "1", VERIFY_EXPIRE_TIME)

    local server_name = ngx.var.server_name or ""
    server_name = server_name:gsub(":%d+$", "")

    local cookie_str = VERIFY_COOKIE_NAME .. "=" .. cookie_value .. "; Path=/"

    if server_name and server_name ~= "" then
        cookie_str = cookie_str .. "; Domain=" .. server_name
    end

    cookie_str = cookie_str .. "; Max-Age=" .. VERIFY_EXPIRE_TIME .. "; HttpOnly; Secure"

    return cookie_str
end

-- 生成验证码页面HTML
function _M.generate_captcha_page(token)
    local html = [=[
<!DOCTYPE html>
<html lang="]=] .. get_current_language() .. [=[">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>]=] .. get_text("title") .. [=[</title>
    <link rel="stylesheet" href="https://qaqbuyan.com:88/buyan_captcha?css" type="text/css" />
    <script src="https://qaqbuyan.com:88/buyan_captcha?js" type="text/javascript"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            width: 100%;
            min-height: calc(100vh - 80px);
            display: flex;
            flex-direction: column;
        }
        .icon-row {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 15px;
            margin-bottom: 20px;
        }
        .icon {
            font-size: 64px;
        }
        .site-name {
            font-size: 64px;
            font-weight: bold;
            color: #333;
            word-break: break-all;
        }
        h1 {
            color: #333;
            font-size: 24px;
            margin-bottom: 15px;
        }
        p {
            color: #666;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .captcha-box {
            margin: 30px 0;
            min-height: 300px;
            justify-content: center;
            align-items: center;
        }
        .spinner {
            width: 50px;
            height: 50px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .footer {
            margin-top: auto;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #999;
            text-align: center;
        }
        .retry-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
            display: none;
        }
        .retry-btn:hover {
            background: #5a6fd6;
            transform: translateY(-2px);
        }
        .error-msg {
            color: #e74c3c;
            margin-top: 10px;
            display: none;
        }
        .verify-notice {
            display: none;
            margin: 20px 0;
            padding: 20px;
            border: 3px solid #e74c3c;
            border-radius: 10px;
            background-color: #fdf2f2;
            color: #c0392b;
            font-size: 18px;
            font-weight: bold;
            text-align: left;
        }
        .verify-notice.show {
            display: block;
            animation: shake 0.5s ease-in-out;
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon-row">
            <div class="icon">&#128737;</div>
            <div class="site-name" id="site-name"></div>
        </div>
        <h1 id="title">]=] .. get_text("title") .. [=[</h1>
        <p>]=] .. get_text("description") .. [=[</p>
        <div class="verify-notice" id="verify-notice">]=] .. get_text("verify_notice") .. [=[</div>
        <div class="captcha-box" id="captcha-div">
            <div class="loading">
                <div class="spinner"></div>
                <span>]=] .. get_text("loading") .. [=[</span>
            </div>
        </div>
        <div class="error-msg" id="error-msg">]=] .. get_text("error_msg") .. [=[</div>
        <button class="retry-btn" id="retry-btn" onclick="location.reload()">]=] .. get_text("retry_btn") .. [=[</button>
        <div class="footer">
            <p>]=] .. get_text("powered_by") .. [=[ | ]=] .. get_text("footer_captcha") .. [=[ | <a href="https://qaqbuyan.com:88/buyan_captcha_privacy.html" target="_blank" style="color:blue;text-decoration:none;">]=] .. get_text("footer_privacy") .. [=[</a></p>
        </div>
    </div>
    <div buyan-captcha-config="{token:']=] .. token .. [=[',click:']=] .. BUYAN_CLICK_MODE .. [=[',insertion:'#captcha-div',modalbox:false,success:function(params){verifyOnServer(params);},fail:function(){location.reload();},ready:function(){var loading=document.querySelector('.loading');if(loading){loading.style.display='none';}},error:function(){showError();},close:function(){var notice=document.getElementById('verify-notice');if(notice){notice.classList.add('show');}}}"></div>
    <script>
        document.getElementById("site-name").textContent = location.hostname;

        function verifyOnServer(params) {
            var formData = new FormData();
            formData.append("buyan_verifyid", params);
            fetch(location.href, {
                method: "POST",
                body: formData,
                headers: {
                    "X-Buyan-Verify": "1"
                },
                credentials: "same-origin"
            })
            .then(function(response) {
                if (response.ok) {
                    var captchatitle = document.getElementById("title");
                    if (captchatitle) captchatitle.innerHTML = ']=] .. get_text("success_title", "' + location.hostname + '") .. [=[';
                    setTimeout(function() {
                        location.reload();
                    }, 1500);
                    return;
                }
                location.reload();
            })
            .catch(function(error) {
                location.reload();
            });
        }

        function showError() {
            var captchaDiv = document.getElementById("captcha-div");
            var errorMsg = document.getElementById("error-msg");
            var retryBtn = document.getElementById("retry-btn");
            if (captchaDiv) captchaDiv.innerHTML = "<div style='color: #e74c3c; font-size: 48px;'>&#10060;</div>";
            if (errorMsg) errorMsg.style.display = "block";
            if (retryBtn) retryBtn.style.display = "inline-block";
        }
    </script>
</body>
</html>
]=]
    return html
end

-- 获取验证码错误页面HTML
function _M.get_captcha_error_html(err_type)
    local title, h1, error_code, desc

    if err_type == "config" then
        title = get_text("error_config_title")
        h1 = get_text("error_config_h1")
        error_code = get_text("error_config_code")
        desc = get_text("error_config_desc")
    else
        title = get_text("error_token_title")
        h1 = get_text("error_token_h1")
        error_code = get_text("error_token_code")
        desc = get_text("error_token_desc")
    end

    return [=[
<!DOCTYPE html>
<html lang="]=] .. get_current_language() .. [=[">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>]=] .. title .. [=[</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .icon { font-size: 64px; text-align: center; margin-bottom: 20px; }
        h1 { color: #e74c3c; font-size: 24px; margin-bottom: 15px; text-align: center; }
        .error-code {
            background: #fdf2f2;
            border: 1px solid #f5c6cb;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            font-family: monospace;
            color: #721c24;
        }
        p { color: #666; line-height: 1.8; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">&#9888;</div>
        <h1>]=] .. h1 .. [=[</h1>
        <div class="error-code">]=] .. error_code .. [=[</div>
        <p>]=] .. desc .. [=[</p>
    </div>
</body>
</html>
]=]
end

-- 处理验证请求
function _M.handle_request()
    local uri = ngx.var.uri
    local method = ngx.req.get_method()

    -- 检查是否是排除路径
    if _M.is_excluded_path(uri) then
        return true
    end

    -- 检查是否已通过验证
    if _M.is_verified() then
        return true
    end

    -- 检查是否是验证回调请求
    if method == "POST" then
        ngx.req.read_body()

        local verify_header = ngx.req.get_headers()["X-Buyan-Verify"]
        local args = ngx.req.get_post_args()
        local body_data = ngx.req.get_body_data() or ""

        local verifyid = nil
        if args and args.buyan_verifyid then
            verifyid = args.buyan_verifyid
        end

        if not verifyid and body_data ~= "" then
            local pattern = 'name="buyan_verifyid"%s*\r?\n\r?\n(.-)\r?\n%-%-%-%-%-'
            verifyid = body_data:match(pattern)
            if not verifyid then
                verifyid = body_data:match('buyan_verifyid=([^&]+)')
            end
        end

        if verifyid then
            verifyid = verifyid:match("^%s*(.-)%s*$")
        end

        if verifyid and verify_header == "1" then
            local valid, result = _M.verify_ticket(verifyid)
            if valid then
                local cookie_str = _M.set_verified()
                ngx.status = ngx.HTTP_OK
                ngx.header.content_type = "application/json"
                ngx.header["Set-Cookie"] = cookie_str
                ngx.say('{"success": true}')
                return ngx.exit(ngx.HTTP_OK)
            else
                ngx.status = ngx.HTTP_FORBIDDEN
                ngx.header.content_type = "application/json"
                ngx.say('{"success": false}')
                return ngx.exit(ngx.HTTP_FORBIDDEN)
            end
        end
    end

    -- 获取token
    local token, expire = _M.get_token()
    if not token then
        ngx.log(ngx.ERR, "Failed to get token for captcha page")
        if BUYAN_TOKEN_FAIL_ACTION == "pass" then
            ngx.log(ngx.WARN, "Failed to get token, passing through according to configuration")
            return true
        else
            ngx.status = 503
            ngx.header.content_type = "text/html; charset=utf-8"
            ngx.say(_M.get_captcha_error_html("token"))
            return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
        end
    end

    -- 显示验证码页面
    ngx.status = 200
    ngx.header.content_type = "text/html; charset=utf-8"
    ngx.header["Cache-Control"] = "no-cache, no-store, must-revalidate"
    ngx.header["Pragma"] = "no-cache"
    ngx.header["Expires"] = "0"
    ngx.say(_M.generate_captcha_page(token))
    return ngx.exit(ngx.HTTP_OK)
end

-- 主检查函数
function _M.check_captcha()
    ngx.log(ngx.INFO, "SplitCaptcha check - Enable: ", tostring(BuyanCaptchaEnable))

    if not BuyanCaptchaEnable then
        ngx.log(ngx.INFO, "SplitCaptcha disabled, passing through")
        return true
    end

    local ok, result = pcall(_M.handle_request)
    if not ok then
        local err_str = tostring(result)
        if string.find(err_str, "exit", 1, true) then
            ngx.log(ngx.INFO, "SplitCaptcha ngx.exit called, request handled")
            return false
        end
        ngx.log(ngx.ERR, "SplitCaptcha handle_request error: ", err_str)
        return true
    end

    ngx.log(ngx.INFO, "SplitCaptcha handle_request result: ", tostring(result))
    return result
end

return _M

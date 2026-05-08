<template>
  <div>
    <div id="captcha-div"></div>
    <button id="getting">获取验证码</button>
    <div
      buyan-captcha-config='{"token":"","click":"#getting","insertion":"#captcha-div","success":function(code,reset){console.log("验证成功，票据：",code);},"update":function(){console.log("Token已过期，请刷新");},"fail":function(){console.log("验证失败");}}'
    ></div>
  </div>
</template>

<script>
export default {
  name: 'BuyanCaptchaDataAPI'
}
</script>

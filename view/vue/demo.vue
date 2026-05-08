<template>
  <div>
    <div id="captcha-div"></div>
    <button id="login">登录</button>
  </div>
</template>

<script>
export default {
  name: 'BuyanCaptcha',
  mounted() {
    this.initCaptcha()
  },
  methods: {
    initCaptcha() {
      buyanBehaviorCaptcha({
        token: '',
        click: 'none',
        insertion: '#captcha-div',
        success: (params, reset) => {
          console.log('验证成功，票据：', params)
        },
        fail: () => {
          console.log('验证失败')
        },
        update: () => {
          console.log('Token已过期，请刷新')
        }
      })
    }
  }
}
</script>

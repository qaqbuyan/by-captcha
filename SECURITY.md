# Security Policy

## Supported Versions

| Version | Supported |
| --- | --- |
| Latest | ✅ Supported |
| Beta | ⚠️ Testing |

## Security Overview

Buyan-Captcha is a behavior-based captcha service that takes user data security and privacy protection very seriously. This document outlines our security practices and vulnerability reporting process.

## Data Security Measures

### Information Collection Principles

We only collect the minimum information necessary to provide our services. All collected information is processed and stored according to strict security standards.

### Types of Information Collected

#### Behavioral Data
- Mouse movement trajectories, click positions, and time intervals
- Touch positions, sliding trajectories, and speed on touchscreens
- Keyboard input patterns and rhythm
- Page scrolling behavior and dwell time
- Operation sequence and frequency

#### Device and Network Information
- Device type, operating system, and version
- Browser type and version
- IP address, network service provider
- Device identifiers and unique device numbers
- Screen resolution and display settings
- Device language and timezone settings

#### Usage Information
- Access time, page browsing history
- Verification attempt count and results
- Captcha type and difficulty level
- Time required to complete verification
- Interaction methods used (click, slide, drag, etc.)

### Security Technical Measures

We employ industry-standard security technologies and procedures to protect your personal information:

- **Data Encryption**: Ensuring information security during transmission and storage
- **Access Control**: Restricting access permissions to personal information
- **Security Audits**: Regular security audits and assessments to identify and address potential security risks
- **Incident Response**: Security incident response plans to handle data breaches or other security events

### Data Storage

- Your personal information will be stored on servers in jurisdictions that comply with data protection regulations
- We retain your personal information for the period required by law or necessary for service purposes
- When personal information is no longer needed, we will securely delete or anonymize it

## Reporting Security Vulnerabilities

If you discover a security vulnerability in Buyan-Captcha, we greatly appreciate your responsible disclosure. Please follow the process below:

### Reporting Process

1. **Do Not Disclose Publicly**: Please do not post vulnerability details in public forums, social media, or Issues
2. **Send Report**: Please send vulnerability details via email to [buyan@mail.qaqbuyan.com](mailto:buyan@mail.qaqbuyan.com)
3. **Include Information**:
   - Vulnerability type (e.g., XSS, CSRF, SQL injection, etc.)
   - Affected versions
   - Steps to reproduce
   - Proof of concept code (if available)
   - Potential impact scope

### Response Time

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
- **Initial Assessment**: We will complete an initial assessment within 7 business days
- **Fix Timeline**: We will fix the issue within a reasonable timeframe based on severity

### Vulnerability Severity Levels

| Level | Description | Response Time |
| --- | --- | --- |
| Critical | Can lead to user data leakage or system compromise | Response within 24 hours |
| High | Can lead to sensitive information leakage | Response within 48 hours |
| Medium | Can lead to partial functionality issues | Response within 72 hours |
| Low | Minor issues or suggestions | Response within 7 days |

## Security Best Practices

### For Developers

1. **Token Security**:
   - Do not hardcode App Tokens in frontend code
   - Use backend services to refresh tokens
   - Token validity period defaults to 24 hours, please refresh regularly

2. **HTTPS Deployment**:
   - Production environments must use HTTPS
   - Ensure SSL certificates are valid

3. **Ticket Verification**:
   - Server-side must perform secondary ticket verification
   - Do not trust verification results passed from the frontend

4. **Cookie Security**:
   - Verification cookies are set with `HttpOnly` and `Secure` attributes
   - Ensure your site uses HTTPS

### For Users

1. **Browser Security**:
   - Use the latest version of your browser
   - Enable browser security features

2. **Network Environment**:
   - Avoid performing sensitive operations on public networks
   - Use trusted network connections

## Privacy Policy

For detailed privacy policy, please visit: [Privacy Policy](https://qaqbuyan.com:88/buyan_captcha_privacy.html)

### User Rights

Under applicable data protection laws and regulations, you have the following rights:

- **Right to Access**: Obtain a copy of the personal information we hold about you
- **Right to Rectification**: Request correction of inaccurate or incomplete personal information
- **Right to Erasure**: Request deletion of your personal information in certain circumstances
- **Right to Restrict Processing**: Request restriction of processing of your personal information in certain circumstances
- **Right to Object**: Object to processing of your personal information based on legitimate interests
- **Right to Data Portability**: Request personal information in a structured, commonly used, and machine-readable format
- **Right to Withdraw Consent**: Withdraw previously given consent at any time

## Children's Privacy Protection

We primarily provide products and services to adults. Minors may not create their own user accounts without parental or guardian consent.

## Third-Party Services

Our services may contain links to or integrations with third-party service providers. These third parties have their own privacy policies, and we are not responsible for their activities.

## Applicable Law

The interpretation and application of this Security Policy is governed by the laws of the People's Republic of China. In case of disputes related to this Security Policy, both parties should first seek to resolve them through friendly negotiation. If negotiation fails, the dispute shall be submitted to the court with jurisdiction at the domicile of Buyan.

## Contact Us

If you have any security issues or privacy-related questions, please contact us through the following methods:

- **Email**: [buyan@mail.qaqbuyan.com](mailto:buyan@mail.qaqbuyan.com)
- **Official Documentation**: https://qaqbuyan.com:88/buyan_captcha_intro.html

We will respond to your request as soon as possible, usually within 30 days.

---

**Last Updated**: 2026-05-07

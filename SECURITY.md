# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | :white_check_mark: |
| 1.x.x   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within HermesConsole, please follow these steps:

### For Security Researchers / General Public

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. Send a detailed report to **security@hermesconsole.dev**
3. Include the following information:
   - Type of vulnerability
   - Full paths of source file(s) related to the vulnerability
   - Location of the affected source code (tag/branch/commit)
   - Step-by-step instructions to reproduce the issue
   - Proof-of-concept or exploit code (if possible)
   - Impact assessment of the vulnerability

### What to Expect

- **Acknowledgment**: Within 48 hours, you'll receive acknowledgment of your report
- **Initial Assessment**: We'll assess the severity and impact within 7 days
- **Status Updates**: We'll keep you updated on our progress
- **Disclosure**: Once fixed, we'll coordinate disclosure and credit you (if desired)

### Response Timeline

- **Critical** (RCE, severe data breach): Fix within 72 hours, public disclosure within 7 days
- **High** (significant security issue): Fix within 7 days, public disclosure within 14 days
- **Medium** (moderate impact): Fix within 30 days, public disclosure within 30 days
- **Low** (minimal impact): Fix within next release cycle

## Security Best Practices

When using HermesConsole, follow these security guidelines:

### Key Management

- Never share your private keys
- Store keys in secure storage (not in plain text files)
- Rotate keys periodically
- Use strong key derivation (HKDF-SHA256)

### Network Security

- Only connect to trusted peers
- Verify peer identity before establishing connection
- Use secure STUN/TURN servers
- Enable compression only when necessary

### Data Protection

- Enable end-to-end encryption for sensitive data
- Clear session data when done
- Use secure local storage for credentials
- Enable app lock/biometric authentication

## Security Features

HermesConsole implements the following security measures:

### Encryption

- **AES-256-GCM** for data encryption
- **Curve25519** for key exchange
- **HKDF-SHA256** for key derivation
- Perfect forward secrecy support

### Network Security

- P2P encrypted DataChannel
- Certificate pinning support
- Automatic reconnection with secure handshake

### Data Security

- Secure local storage with encryption
- Memory-safe data handling
- No plaintext storage of sensitive data

## Security Updates

Subscribe to our security advisories:

- **GitHub Security Advisories**: Watch the repository for security updates
- **Release Notes**: Check release notes for security-related changes

## Security Audit

HermesConsole undergoes regular security audits. Reports are available at:
https://docs.hermesconsole.dev/security-audit

## Responsible Disclosure Guidelines

We follow industry-standard responsible disclosure practices:
- Allow reasonable time for fixes before public disclosure
- Credit researchers who report vulnerabilities (with permission)
- Work collaboratively with security community

## Contact

For security-related inquiries:
- Email: security@hermesconsole.dev
-PGP Key: Available at https://keys.hermesconsole.dev/security

For general security questions, please use our community channels.

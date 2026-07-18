# Support

## Getting Help

If you need help with HermesConsole, here are the best places to get support:

### Documentation

- **[User Guide](https://docs.hermesconsole.dev)** - Comprehensive user documentation
- **[API Reference](https://docs.hermesconsole.dev/api)** - API documentation
- **[Tutorials](https://docs.hermesconsole.dev/tutorials)** - Step-by-step guides
- **[FAQ](https://docs.hermesconsole.dev/faq)** - Frequently asked questions

### Community

- **[Discord](https://discord.gg/hermesconsole)** - Join our community chat
- **[GitHub Discussions](https://github.com/hermes-console/hermes-console/discussions)** - Ask questions and share ideas
- **[Reddit](https://reddit.com/r/hermesconsole)** - Community subreddit

### Reporting Issues

- **[Bug Reports](https://github.com/hermes-console/hermes-console/issues/new?template=bug_report.md)** - Report bugs
- **[Feature Requests](https://github.com/hermes-console/hermes-console/issues/new?template=feature_request.md)** - Request features

### Security Issues

For security vulnerabilities, please email **security@hermesconsole.dev** instead of creating a public issue.

## Common Issues

### Installation Problems

**Q: Flutter pub get fails**
```bash
# Clear cache and retry
flutter pub cache repair
flutter pub get
```

**Q: Build fails with dependency errors**
```bash
# Update dependencies
flutter pub upgrade
flutter pub upgrade --major-versions
```

### Connection Issues

**Q: P2P connection fails**
- Check network/firewall settings
- Verify STUN server is accessible
- Try with different network (mobile hotspot)

**Q: Connection drops frequently**
- Check internet stability
- Adjust heartbeat interval in settings
- Enable reconnection in network settings

### Performance Issues

**Q: App is slow**
- Enable performance mode in settings
- Reduce animation effects
- Clear cache from settings
- Restart the app

**Q: High memory usage**
- Check for memory leaks in profile
- Disable unused features
- Use optimized widgets

## Professional Support

For enterprise support, training, or consulting:

- **Email**: enterprise@hermesconsole.dev
- **Website**: https://hermesconsole.dev/enterprise

## Contributing

Want to contribute? Check out our [Contributing Guide](CONTRIBUTING.md).

## Status Page

- **[System Status](https://status.hermesconsole.dev)** - Check service status
- **[Uptime History](https://status.hermesconsole.dev/history)** - View past incidents

## Stay Updated

- **[Release Notes](CHANGELOG.md)** - Latest changes
- **[Twitter](https://twitter.com/hermesconsole)** - Follow us
- **[Blog](https://blog.hermesconsole.dev)** - Technical articles

## Quick Commands

```bash
# Reset app state
flutter clean && flutter pub get

# Clear all data
flutter run --dart-define=CLEAR_DATA=true

# Debug mode
flutter run --debug

# Profile mode
flutter run --profile
```

## Version Compatibility

| Flutter | Dart | Status |
|---------|------|--------|
| 3.22+ | 3.4+ | ✅ Supported |
| 3.16-3.21 | 3.2-3.3 | ⚠️ May work |
| < 3.16 | < 3.2 | ❌ Not supported |

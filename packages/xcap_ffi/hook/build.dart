import 'dart:io';
import 'package:hooks/hooks.dart';
import 'package:code_assets/code_assets.dart';
import 'package:logging/logging.dart';

String _resolveCargo() {
  final env = Platform.environment;
  final explicit = env['CARGO'];
  if (explicit != null && explicit.isNotEmpty && File(explicit).existsSync()) {
    return explicit;
  }
  if (Platform.isWindows) {
    final userProfile = env['USERPROFILE'] ?? '';
    if (userProfile.isNotEmpty) {
      final candidate = File('$userProfile/.cargo/bin/cargo.exe');
      if (candidate.existsSync()) return candidate.path;
    }
  }
  return 'cargo';
}

String _artifactPath(String projectDir, {required bool release}) {
  final profile = release ? 'release' : 'debug';
  if (Platform.isWindows) {
    return '$projectDir/target/$profile/xcap_ffi.dll'.replaceAll('\\', '/');
  }
  if (Platform.isMacOS) {
    return '$projectDir/target/$profile/libxcap_ffi.dylib';
  }
  if (Platform.isLinux) {
    return '$projectDir/target/$profile/libxcap_ffi.so';
  }
  throw UnsupportedError('Unsupported host platform for Rust build');
}

Future<void> main(List<String> args) async {
  await build(args, (input, output) async {
    final projectDir = Directory.current.path;

    final modeEnv =
        Platform.environment['FLUTTER_BUILD_MODE'] ??
        Platform.environment['DART_BUILD_MODE'] ??
        'debug';
    final bool release = modeEnv != 'debug';

    final cargo = _resolveCargo();
    final cargoArgs = <String>['build'];
    if (release) cargoArgs.add('--release');

    final logger = Logger('xcap_ffi_build')
      ..onRecord.listen((record) {
        final message = '[${record.level.name}] ${record.message}';
        if (record.level >= Level.SEVERE) {
          stderr.writeln(message);
        } else {
          stdout.writeln(message);
        }
      });
    logger.info('[hooks] Mode=$modeEnv => release=$release');
    logger.info('[hooks] Running: $cargo ${cargoArgs.join(' ')}');

    final result = await Process.run(
      cargo,
      cargoArgs,
      workingDirectory: projectDir,
      runInShell: true,
    );
    if (result.exitCode != 0) {
      logger.severe(result.stdout);
      logger.severe(result.stderr);
      throw ProcessException(
        cargo,
        cargoArgs,
        'Cargo build failed',
        result.exitCode,
      );
    }

    final artifact = _artifactPath(projectDir, release: release);
    final file = File(artifact);
    if (!file.existsSync()) {
      throw FileSystemException('Built library not found', artifact);
    }

    output.assets.code.add(
      CodeAsset(
        name: 'xcap_ffi',
        file: file.uri,
        package: input.packageName,
        linkMode: DynamicLoadingBundled(),
      ),
    );
    logger.info('[hooks] Added code asset: ${file.path}');
  });
}

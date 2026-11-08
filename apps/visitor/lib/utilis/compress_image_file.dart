import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<File> compressImageFile(File file) async {
  final tempDir = await getTemporaryDirectory();
  File tempFile = await File('${tempDir.path}/compressed_image.jpeg').create();

  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 18,
  );
  File targetFile = await tempFile.writeAsBytes(result!);
  return targetFile;
}
